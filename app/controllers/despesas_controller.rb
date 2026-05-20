class DespesasController < ApplicationController
  before_action :set_despesa, only: %i[ show edit update destroy ]

  # GET /despesas
  def index
    # 1. Guarda os parâmetros de data para persistir nos campos da View
    @data_inicio = params[:data_inicio]
    @data_fim = params[:data_fim]

    # 2. SISTEMA DE PERMISSÕES AJUSTADO PARA O PEDIDO DO PROFESSOR
    if current_funcionario.admin?
      base_despesas = Despesa.all
    else
      # IMPORTANTE: Removemos o session[:unidade_atual] para funcionários comuns.
      # Agora, eles ficam blindados e só enxergam a unidade cadastrada no perfil deles.
      base_despesas = Despesa.where(unidade: current_funcionario.unidade)
    end

    # 3. FILTRO DE DATA INTELIGENTE (Mantém sua lógica perfeita de antes)
    if @data_inicio.present? && @data_fim.present?
      @despesas = base_despesas.where(data_pagamento: @data_inicio.to_date.beginning_of_day..@data_fim.to_date.end_of_day)
    else
      @despesas = base_despesas
    end

    # 4. Mantém a ordenação decrescente por padrão
    @despesas = @despesas.order(data_pagamento: :desc)
    
    # 5. Soma total das despesas filtradas para exibição no Dashboard
    @total_despesas = @despesas.sum(:valor)
  end

  # GET /despesas/1
  def show
  end

  # GET /despesas/new
  def new
    @despesa = Despesa.new
  end

  # GET /despesas/1/edit
  def edit
  end

  # POST /despesas
# POST /despesas
def create
  @despesa = Despesa.new(despesa_params)
  
  @despesa.funcionario = current_funcionario
  @despesa.unidade = session[:unidade_atual] || current_funcionario.unidade
  @despesa.turno = session[:turno_atual] || current_funcionario.turno

  # LÓGICA DEFINITIVA: Aplica o fuso local antes de enviar para o banco UTC
  if @despesa.data_pagamento.present?
    @despesa.data_pagamento = @despesa.data_pagamento.to_time.beginning_of_day + 12.hours
  end

  if @despesa.data_vencimento.present?
    @despesa.data_vencimento = @despesa.data_vencimento.to_time.beginning_of_day + 12.hours
  end

  respond_to do |format|
    if @despesa.save
      format.html { redirect_to despesas_path, notice: "Despesa registrada com sucesso!" }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end

  # PATCH/PUT /despesas/1
  def update
    respond_to do |format|
      if @despesa.update(despesa_params)
        format.html { redirect_to despesas_path, notice: "Despesa atualizada com sucesso!", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /despesas/1
  def destroy
    @despesa.destroy!

    respond_to do |format|
      format.html { redirect_to despesas_path, notice: "Despesa eliminada.", status: :see_other }
    end
  end

  private
    # Callback para encontrar a despesa pelo ID
    def set_despesa
      @despesa = Despesa.find(params[:id])
    end

    # Parâmetros permitidos via formulário
    def despesa_params
      # Unidade, Turno e Funcionário são omitidos aqui pois o Controller os define por segurança
      params.require(:despesa).permit(:descricao, :categoria, :valor, :data_pagamento, :data_vencimento, :pago)
    end
end