class NotificacaosController < ApplicationController
  # Garante que apenas usuários logados acessem (se você usar Devise)
  before_action :authenticate_funcionario! 

  def index
    # Traz as notificações mais recentes primeiro
    @notificacoes = Notificacao.order(created_at: :desc)
  end

  def marcar_como_lida
    @notificacao = Notificacao.find(params[:id])
    @notificacao.update(lida: true)

    # Retorna para a mesma página onde o usuário clicou
    redirect_back fallback_location: notificacaos_path, notice: "Alerta marcado como lido!"
  end
end
