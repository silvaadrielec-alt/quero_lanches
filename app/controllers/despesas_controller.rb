class DespesasController < ApplicationController
  before_action :set_despesa, only: %i[ show edit update destroy ]
  before_action :authenticate_funcionario!

  def index
    @data_inicio = params[:data_inicio]
    @data_fim = params[:data_fim]

    # Escopo de segurança: Funcionários comuns não veem despesas de outras unidades
    # Escopo de segurança: Funcionários comuns não veem despesas de outras unidades
    @despesas = current_funcionario.admin? ? Despesa.all : Despesa.where(unidade_id: current_funcionario.unidade_id)

    if @data_inicio.present? && @data_fim.present?
      @despesas = @despesas.where(data_pagamento: @data_inicio.to_date..@data_fim.to_date)
    end

    @despesas = @despesas.order(data_pagamento: :desc)
    @total_despesas = @despesas.sum(:valor)
  end

# 2. Adicionamos o método 'show' que estava faltando
  def show
    # @despesa já foi carregada pelo set_despesa lá em cima
   end

  # 3. Adicionamos o método 'new' que estava faltando
  def new
    @despesa = Despesa.new
   end

  def create
  @despesa = Despesa.new(despesa_params)
  @despesa.funcionario = current_funcionario
  
  # AQUI ESTÁ A CORREÇÃO:
  # Pegamos o ID da unidade atual da sessão ou do funcionário
  # E atribuímos ao campo unidade_id
  @despesa.unidade_id = session[:unidade_id] || current_funcionario.unidade_id
  
  @despesa.turno = session[:turno_atual] || current_funcionario.turno

  if @despesa.save
    redirect_to despesas_path, notice: "Despesa registrada!"
  else
    render :new, status: :unprocessable_entity
  end
end

  def edit
    # O set_despesa já carrega o objeto para a edição
    end

  def update
    if @despesa.update(despesa_params)
      @despesa.auditar_alteracao(current_funcionario.id)
      redirect_to despesas_path, notice: "Despesa atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @despesa.auditar_exclusao(current_funcionario.id)
    @despesa.destroy!
    redirect_to despesas_path, notice: "Despesa eliminada.", status: :see_other
  end

  private

  def set_despesa
    @despesa = Despesa.find(params[:id])
  end

  def despesa_params
    params.require(:despesa).permit(:descricao, :categoria, :unidade_id, :valor, :data_pagamento, :data_vencimento, :pago)
  end
end