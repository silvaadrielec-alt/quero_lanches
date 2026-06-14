class FluxoDeCaixaController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    @periodo = params[:periodo] || 'mensal'
    @unidade = params[:unidade].presence 

    case @periodo
    when 'diario'
      @range = Time.current.beginning_of_day..Time.current
    when 'semanal'
      @range = 7.days.ago.beginning_of_day..Time.current
    when 'mensal'
      @range = 30.days.ago.beginning_of_day..Time.current
    when 'anual'
      @range = 1.year.ago.beginning_of_day..Time.current
    when 'personalizado'
      @data_inicio = params[:data_inicio].presence ? Date.parse(params[:data_inicio]) : Date.current.beginning_of_month
      @data_fim = params[:data_fim].presence ? Date.parse(params[:data_fim]) : Date.current.end_of_month
      @range = @data_inicio.beginning_of_day..@data_fim.end_of_day
    else
      @range = 30.days.ago.beginning_of_day..Time.current
    end

    # --- ESCOPO DINÂMICO CONCILIADO ---
    pedidos_escopo = Pedido.where(created_at: @range)
    
    # Captura despesas da tabela de contas administrativas
    despesas_escopo = Despesa.where(pago: true, updated_at: @range)
    
    # Captura despesas de compras de estoque se a tabela global financeira existir
    movimentacoes_financeiras = defined?(MovimentacaoFinanceira) ? MovimentacaoFinanceira.where(tipo: 'DESPESA', created_at: @range) : nil

    if @unidade.present?
      pedidos_escopo = pedidos_escopo.where(unidade: @unidade)
      despesas_escopo = despesas_escopo.where(unidade: @unidade)
      movimentacoes_financeiras = movimentacoes_financeiras.where(unidade: @unidade.upcase.gsub('_', ' ')) if movimentacoes_financeiras
    end

    # 1. ENTRADAS BRUTAS (FATURAMENTO)
    @total_entradas = pedidos_escopo.sum(:valor_total)

    # 2. SAÍDAS OPERACIONAIS CONSOLIDADAS
    # Soma as despesas fixas (contas) com as compras de insumos em lote do estoque
    @total_saidas_administrativas = despesas_escopo.sum(:valor)
    @total_saidas_estoque = movimentacoes_financeiras ? movimentacoes_financeiras.sum(:valor) : 0.0
    @total_saidas = @total_saidas_administrativas + @total_saidas_estoque

    # 3. CUSTO DE INSUMOS DAS MERCADORIAS VENDIDAS (CMV)
    @total_custo_insumos = 0.0
    
    # 🌟 BLINDAGEM DE MEMÓRIA: find_each processa em lotes de 100, evitando travar o servidor da filial
    pedidos_escopo.includes(item_pedidos: [{ produto: { composicoes: :insumo } }, { item_pedido_adicionais: :insumo }]).find_each(batch_size: 100) do |pedido|
      
      pedido.item_pedidos.each do |item|
        prod = item.produto
        next unless prod

        qtd_item = item.quantidade.to_f

        # A) Custo de Itens de Revenda Direta (que possuem estoque próprio e custo na tabela produto)
        if prod.respond_to?(:preco_custo) && prod.preco_custo.to_f > 0 && prod.composicoes.empty?
          # Usa o fator de proporção da model de pedidos que já calibramos (ex: lata, garrafa)
          fator = pedido.respond_to?(:descobrir_fator_proporcao, true) ? pedido.send(:descobrir_fator_proporcao, prod, item) : 1.0
          @total_custo_insumos += (prod.preco_custo.to_f * fator * qtd_item)
        end

        # B) Custo das Fichas Técnicas dos Produtos de Fabricação (Pastel, Misto, etc.)
        prod.composicoes.each do |comp|
          insumo = comp.insumo
          next unless insumo && insumo.preco_custo.present?
          
          # Pula se o insumo foi removido pelo operador na observação da linha
          next if pedido.observacao.to_s.downcase.include?(insumo.nome.to_s.downcase.strip)

          # Recorre à inteligência de conversão de unidades (G, ML, FATIA -> KG) da Model Pedido
          if pedido.respond_to?(:calcular_quantidade_real, true)
            qtd_real_insumo = pedido.send(:calcular_quantidade_real, comp, item)
          else
            qtd_real_insumo = comp.quantidade.to_f
          end

          @total_custo_insumos += (insumo.preco_custo.to_f * qtd_real_insumo * qtd_item)
        end

        # C) Custo dos Adicionais Extras selecionados no checkout
        item.item_pedido_adicionais.each do |ipa|
          add_insumo = ipa.insumo
          next unless add_insumo && add_insumo.preco_custo.present?
          
          qtd_add = ipa.quantidade.to_f
          @total_custo_insumos += (add_insumo.preco_custo.to_f * qtd_add * qtd_item)
        end
      end
    end

    # 4. SALDO LÍQUIDO REAL CONCILIADO
    @saldo_liquido = @total_entradas - @total_custo_insumos - @total_saidas

    # Amostras para exibição rápida em tabelas de auditoria visual
    @pedidos_detalhados = pedidos_escopo.order(created_at: :desc).limit(10)
    @despesas_detalhadas = despesas_escopo.order(updated_at: :desc).limit(10)
  end
  
  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência financeira do sistema." unless current_funcionario.admin?
  end
end