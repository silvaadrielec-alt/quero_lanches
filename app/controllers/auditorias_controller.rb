class AuditoriasController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
   @auditorias = Auditoria.where.not(tabela_afetada: 'movimentacaos')
                           .includes(:funcionario)
                           .order(created_at: :desc)
                           .limit(500)
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência e auditoria." unless current_funcionario.admin?
  end
end