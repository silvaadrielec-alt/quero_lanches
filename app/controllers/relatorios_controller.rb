class RelatoriosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin # Apenas admin vê o faturamento!

  def index
    @total_geral = Pedido.sum(:valor_total)
    @vendas_matriz = Pedido.where(unidade: 'centro').sum(:valor_total)
    @vendas_pavilhao_novo = Pedido.where(unidade: 'pavilhao_novo').sum(:valor_total)
    @vendas_pavilhao_antigo = Pedido.where(unidade: 'pavilhao_antigo').sum(:valor_total)
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência." unless current_funcionario.admin?
  end
end
