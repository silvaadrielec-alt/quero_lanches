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
  
  @funcionario.admin = true
  @funcionario.role = "admin"
  @funcionario.cargo = "Dono"
  
  # CORREÇÃO: Busca a unidade pelo nome ou cria se não existir, 
  # e atribui o ID através da associação.
  unidade_matriz = Unidade.find_or_create_by!(nome: "Matriz")
  @funcionario.unidade = unidade_matriz
  
  @funcionario.turno = "Integral"

  if @funcionario.save
    sign_in(@funcionario)
    redirect_to root_path, notice: "Bem-vindo! Sua conta de Administrador Geral foi criada com sucesso."
  else
    render :index, status: :unprocessable_entity
  end
end

  private

  def setup_params
    # MUDANÇA AQUI: Adicionamos o :codigo_autorizacao na lista de permissões
    params.require(:funcionario).permit(:nome, :email, :codigo_autorizacao, :password, :password_confirmation)
  end
end