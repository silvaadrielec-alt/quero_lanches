class DespesasController < ApplicationController
  before_action :set_despesa, only: %i[ show edit update destroy ]

  # GET /despesas
  def index
    # Filtramos apenas as despesas da unidade onde o funcionário fez check-in
    @despesas = Despesa.where(unidade: session[:unidade_atual]).order(data_pagamento: :desc)
    
    # Criamos a soma total para exibir no topo da página
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
  def create
    @despesa = Despesa.new(despesa_params)
    
    # VINCULAÇÃO AUTOMÁTICA: 
    # O sistema identifica sozinho quem é o funcionário e onde ele está.
    @despesa.funcionario = current_funcionario
    @despesa.unidade = session[:unidade_atual]
    @despesa.turno = session[:turno_atual]

    respond_to do |format|
      if @despesa.save
        format.html { redirect_to despesas_path, notice: "Despesa registada com sucesso!" }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_despesa
      @despesa = Despesa.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def despesa_params
      # Note que NÃO incluímos :unidade ou :funcionario_id aqui, 
      # pois eles são preenchidos automaticamente no create por segurança.
      params.require(:despesa).permit(:descricao, :categoria, :valor, :data_pagamento, :pago)
    end
end