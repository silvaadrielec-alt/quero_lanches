class FuncionariosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin, except: [:new, :create]
  before_action :set_funcionario, only: %i[ show edit update destroy ]

  def index
    @funcionarios = Funcionario.all
  end

  def show
  end

  def new
    @funcionario = Funcionario.new
  end

  def edit
  end

  def create
    @funcionario = Funcionario.new(funcionario_params)

    if @funcionario.save
      redirect_to funcionarios_path, notice: "Funcionário cadastrado com sucesso!"
    else
      # Isso ajuda a ver o erro caso falte algo (ex: senha curta)
      render :new, status: :unprocessable_entity
    end
  end

  # --- ADICIONE DAQUI PARA BAIXO ---

  def edit
    # Apenas abre o formulário de edição
  end

  def update
    # Se você não quiser exigir a senha na hora de mudar apenas o e-mail:
    params_para_atualizar = funcionario_params
    if params_para_atualizar[:password].blank?
      params_para_atualizar.delete(:password)
      params_para_atualizar.delete(:password_confirmation)
    end

    if @funcionario.update(params_para_atualizar)
      redirect_to funcionarios_path, notice: "Informações atualizadas com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @funcionario.destroy
    redirect_to funcionarios_path, notice: "Funcionário excluído com sucesso!"
  end

  private

  def set_funcionario
    @funcionario = Funcionario.find(params[:id])
  end

  def funcionario_params
    # Usando require/permit que é o mais seguro para evitar conflitos
    params.require(:funcionario).permit(:nome, :email, :password, :password_confirmation, :admin)
  end

  def verificar_admin
    # Forma mais simples e que não gera erro de sintaxe
    if current_funcionario.nil? || current_funcionario.admin != true
      redirect_to root_path, alert: "Acesso restrito apenas para administradores!"
    end
  end
end
