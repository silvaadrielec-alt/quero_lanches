class RelatoriosController < ApplicationController
  before_action :authenticate_funcionario!
  require 'csv'

  def index
    @data_inicio = params[:data_inicio].presence
    @data_fim = params[:data_fim].presence

    if current_funcionario.admin?
      base_produtos = Produto.all
      base_pedidos = Pedido.all
      base_despesas = Despesa.all
      base_movimentacoes = Movimentacao.all
    else
      base_produtos = Produto.all
      base_pedidos = Pedido.where(unidade: current_funcionario.unidade.nome)
      base_despesas = Despesa.where(unidade: current_funcionario.unidade.nome)
      base_movimentacoes = Movimentacao.where(unidade: current_funcionario.unidade.nome)
    end

    @pedidos_filtrados = base_pedidos.includes(:unidade)
    @despesas_pagas_filtradas = base_despesas.includes(:unidade).where(pago: true)
    @movimentacoes_filtradas = base_movimentacoes.includes(:funcionario, :produto)

    if @data_inicio.present? && @data_fim.present?
      range = Date.parse(@data_inicio).beginning_of_day..Date.parse(@data_fim).end_of_day
      @pedidos_filtrados = @pedidos_filtrados.where(created_at: range)
      
      if Despesa.column_names.include?('data_pagamento')
        @despesas_pagas_filtradas = @despesas_pagas_filtradas.where(data_pagamento: range)
      else
        @despesas_pagas_filtradas = @despesas_pagas_filtradas.where(updated_at: range)
      end
      @movimentacoes_filtradas = @movimentacoes_filtradas.where(created_at: range)
    end

    @produtos_para_comprar = base_produtos.select(&:precisa_reposicao?)
    
    @total_vendas = @pedidos_filtrados.sum(:valor_total)
    @total_despesas = @despesas_pagas_filtradas.sum(:valor)
    @total_custo_insumos = calcular_cmv(@pedidos_filtrados)
    
    @lucro_liquido = @total_vendas - @total_despesas - @total_custo_insumos
    
    @despesas_a_pagar = base_despesas.where(pago: false).order(data_vencimento: :asc)
    @pedidos_recentes = @pedidos_filtrados.order(created_at: :desc)
    @despesas_pagas_detalhado = @despesas_pagas_filtradas.order(updated_at: :desc)
    @movimentacoes = @movimentacoes_filtradas.order(created_at: :desc)
  end

  private

  def calcular_cmv(pedidos)
    custo_total = 0.0
    pedidos.includes(item_pedidos: [{ produto: { composicoes: :insumo } }, { item_pedido_adicionais: :insumo }]).find_each do |pedido|
      pedido.item_pedidos.each do |item|
        prod = item.produto
        next unless prod
        qtd_item = item.quantidade.to_f

        if prod.respond_to?(:preco_custo) && prod.preco_custo.to_f > 0 && prod.composicoes.empty?
          fator = pedido.respond_to?(:descobrir_fator_proporcao, true) ? pedido.send(:descobrir_fator_proporcao, prod, item) : 1.0
          custo_total += (prod.preco_custo.to_f * fator * qtd_item)
        end

        prod.composicoes.each do |comp|
          insumo = comp.insumo
          next unless insumo && insumo.preco_custo.present?
          next if pedido.observacao.to_s.downcase.include?(insumo.nome.to_s.downcase.strip)
          
          qtd_real = pedido.respond_to?(:calcular_quantidade_real, true) ? pedido.send(:calcular_quantidade_real, comp, item) : comp.quantidade.to_f
          custo_total += (insumo.preco_custo.to_f * qtd_real * qtd_item)
        end
      end
    end
    custo_total
  end
end