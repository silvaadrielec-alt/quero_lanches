class ReferenciaRendimentosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    @referencias = ReferenciaRendimento.all
  end

  def create
    @referencia = ReferenciaRendimento.new(params.require(:referencia_rendimento).permit(:insumo_nome, :unidade_medida, :fator))
    if @referencia.save
      redirect_to referencia_rendimentos_path, notice: "Referência criada!"
    else
      redirect_to referencia_rendimentos_path, alert: "Erro ao criar referência."
    end
  end

  def destroy
    ReferenciaRendimento.find(params[:id]).destroy
    redirect_to referencia_rendimentos_path, notice: "Removido."
  end

  private # O PRIVATE DEVE FICAR DENTRO DA CLASSE

  def verificar_admin
    unless current_funcionario.admin?
      redirect_to root_path, alert: "Acesso negado!"
    end
  end
end