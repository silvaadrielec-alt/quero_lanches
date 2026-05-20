class RelatoriosController < ApplicationController
  before_action :authenticate_funcionario!
  require 'csv'

  def index
    # Aplica o sistema de permissões baseado no nível de acesso
    if current_funcionario.admin?
      base_produtos = Produto.all
      base_pedidos = Pedido.all
      base_despesas = Despesa.all
      base_movimentacoes = Movimentacao.all
    else
      # Funcionário comum fica restrito à sua respectiva unidade
      base_produtos = Produto.all # Estoque geralmente é global ou filtrado se tiver campo unidade
      base_pedidos = Pedido.where(unidade: current_funcionario.unidade)
      base_despesas = Despesa.where(unidade: current_funcionario.unidade)
      base_movimentacoes = Movimentacao.where(unidade: current_funcionario.unidade)
    end

    # 1. Dados de Reposição de Estoque
    @produtos_para_comprar = base_produtos.select(&:precisa_reposicao?)
    
    # 2. Dados do Resumo Financeiro / Faturamento (Escopados)
    @total_vendas = base_pedidos.sum(:valor_total)
    @total_despesas = base_despesas.where(pago: true).sum(:valor)
    @lucro_liquido = @total_vendas - @total_despesas
    
    # 3. Despesas a Pagar (Controle de contas pendentes)
    @despesas_a_pagar = base_despesas.where(pago: false).order(data_vencimento: :asc)
    
    # 4. Fluxo de Caixa Recente (Alinhado com as permissões)
    @pedidos_recentes = base_pedidos.order(created_at: :desc).limit(50)
    @despesas_pagas_detalhado = base_despesas.where(pago: true).order(data_pagamento: :desc).limit(50)
    
    # 5. Auditoria do Sistema
    @movimentacoes = base_movimentacoes.order(created_at: :desc).limit(100)
  end

  def auditoria
    @movimentacoes = Movimentacao.all.order(created_at: :desc)
  end

  def exportar_auditoria
    @movimentacoes = Movimentacao.all.order(created_at: :desc)
    
    respond_to do |format|
      format.csv do
        filename = "Auditoria_CantinaTech_#{Date.today}.csv"
        csv_data = CSV.generate(col_sep: ';', force_quotes: true) do |csv|
          csv << ["Data/Hora", "Responsável", "Unidade", "Item", "Ação", "Quantidade"]
          
          @movimentacoes.each do |log|
            csv << [
              log.created_at.strftime("%d/%m/%y %H:%M"),
              log.respond_to?(:responsavel) ? log.responsavel : log.funcionario&.nome,
              log.unidade&.upcase,
              log.respond_to?(:produto_nome) ? log.produto_nome : log.produto&.nome,
              log.respond_to?(:acao) ? log.acao : log.tipo_movimentacao,
              log.respond_to?(:qtd) ? log.qtd : log.quantidade
            ]
          end
        end
        send_data "\xEF\xBB\xBF" + csv_data, filename: filename, type: 'text/csv; charset=utf-8'
      end
    end
  end
end