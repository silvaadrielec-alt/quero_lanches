class HomeController < ApplicationController
  layout "application", except: [:index]

 def index
  if funcionario_signed_in?
    @insumos_criticos = Insumo.all.select { |i| i.respond_to?(:precisa_reposicao?) && i.precisa_reposicao? }
    
    # Busca produtos e força a verificação na instância
    @produtos_criticos = Produto.all.select { |p| p.respond_to?(:precisa_reposicao?) && p.precisa_reposicao? }
    
    render :painel
  else
    render :index
  end
end

def painel
  @insumos_criticos = Insumo.all.select { |i| i.respond_to?(:precisa_reposicao?) && i.precisa_reposicao? }
  @produtos_criticos = Produto.all.select { |p| p.respond_to?(:precisa_reposicao?) && p.precisa_reposicao? }
end
  
  # ... mantenha o seu método def faturamento aqui embaixo intacto ...
  def faturamento
    case params[:periodo]
    when "diario"
      range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    when "semanal"
      range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
    when "mensal"
      range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
    when "trimestral"
      range = 3.months.ago.beginning_of_day..Time.zone.now.end_of_day
    when "semestral"
      range = 6.months.ago.beginning_of_day..Time.zone.now.end_of_day
    when "anual"
      range = Time.zone.now.beginning_of_year..Time.zone.now.end_of_year
    else
      range = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
    end

    @vendas_hoje = Pedido.where(created_at: range)
    @total_faturado = @vendas_hoje.sum(:valor_total)
    
    @lucro_estimado = @vendas_hoje.sum do |pedido|
      custo_unitario = pedido.produto.composicoes.sum { |c| c.quantidade * (c.insumo.valor_unitario || 0) }
      (pedido.valor_total || 0) - (custo_unitario * (pedido.quantidade || 1))
    end

    @mais_vendidos = @vendas_hoje.group(:produto_id)
                                 .select("produto_id, SUM(quantidade) as total_qtd")
                                 .order("total_qtd DESC")
                                 .limit(5)
    @vendas_por_dia = @vendas_hoje.group_by_day(:created_at).sum(:valor_total)
  end
end