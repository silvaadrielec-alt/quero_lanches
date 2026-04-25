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
      render json: @funcionario.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @funcionario.update(funcionario_params)
      redirect_to funcionarios_path, notice: "Funcionário atualizado com sucesso!"
    else
      render :new, status: :unprocessable_entity
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
    params.expect(funcionario: [:nome, :email, :password, :password_confirmation, :admin])
  end

  def verificar_admin
    # Forma mais simples e que não gera erro de sintaxe
    if current_funcionario.nil? || current_funcionario.admin != true
      redirect_to root_path, alert: "Acesso restrito apenas para administradores!"
    end
  end
end
