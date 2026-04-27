 class HomeController < ApplicationController
  # Esta linha diz para não usar o layout padrão (com cabeçalho) na index
  layout "application", except: [:index]

  def index
    # Busca itens com estoque baixo para o alerta
    @estoque_critico = Produto.where("estoque_centro < 10 OR estoque_pavilhao_novo < 10 OR estoque_pavilhao_antigo < 10")

    if funcionario_signed_in?
      render :painel
    else
      # Quando renderizar a index, ele virá sem o cabeçalho global
      render :index
    end
  end

def faturamento
    # Pega todos os pedidos realizados hoje
    @vendas_hoje = Pedido.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    
    # Soma o valor total bruto
    @total_faturado = @vendas_hoje.sum(:valor_total)
    
    # Cálculo do lucro (Preço de venda - Custo da Ficha Técnica)
    @lucro_estimado = @vendas_hoje.sum do |pedido|
      custo_unitario = pedido.produto.composicoes.sum { |c| c.quantidade * (c.insumo.valor_unitario || 0) }
      pedido.valor_total - (custo_unitario * pedido.quantidade)
    end
  end
  end