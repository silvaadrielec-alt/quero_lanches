class SetupController < ApplicationController
  # Importante: Não podemos exigir login aqui, senão o Davi nunca entra!
  skip_before_action :authenticate_funcionario!, only: [:index, :create], raise: false
  skip_before_action :verificar_checkin_turno, only: [:index, :create], raise: false

  def index
    # SEGURANÇA: Se já existir QUALQUER funcionário, bloqueia essa tela.
    # Isso impede que um engraçadinho tente criar um admin extra depois.
    if Funcionario.exists?
      redirect_to root_path, alert: "O sistema já possui um administrador configurado."
    end
  end

  def create
    @funcionario = Funcionario.new(setup_params)
    @funcionario.admin = true # O primeiro usuário é OBRIGATORIAMENTE o dono (Admin)

    if @funcionario.save
      sign_in(@funcionario) # Faz o login automático para facilitar a vida do Davi
      redirect_to root_path, notice: "Bem-vindo, Davi! Sua conta de Administrador Geral foi criada com sucesso."
    else
      # Se houver erro (ex: senha curta ou e-mail inválido), volta para o form
      render :index, status: :unprocessable_entity
    end
  end

  private

  def setup_params
    # Permitimos apenas os campos básicos para o primeiro acesso
    params.require(:funcionario).permit(:nome, :email, :password, :password_confirmation)
  end
end