class AuditoriasController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    # 🌟 CORREÇÃO DE INFLEXÃO: Apontamos explicitamente para o model 'Auditorium'
    # para o Rails não tentar adivinhar o plural em inglês/português.
    @auditorias = Auditorium.includes(:funcionario).order(created_at: :desc)
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência e auditoria." unless current_funcionario.admin?
  end
end