class MovimentacaosController < ApplicationController
  before_action :set_movimentacao, only: %i[ show edit update destroy ]

  # GET /movimentacaos or /movimentacaos.json
  def index
    @movimentacaos = Movimentacao.all
  end

  # GET /movimentacaos/1 or /movimentacaos/1.json
  def show
  end

  # GET /movimentacaos/new
  def new
    @movimentacao = Movimentacao.new
  end

  # GET /movimentacaos/1/edit
  def edit
  end

  # POST /movimentacaos or /movimentacaos.json
  def create
    @movimentacao = Movimentacao.new(movimentacao_params)

    respond_to do |format|
      if @movimentacao.save
        format.html { redirect_to @movimentacao, notice: "Movimentação cadastrada com sucesso!" }
        format.json { render :show, status: :created, location: @movimentacao }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movimentacao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movimentacaos/1 or /movimentacaos/1.json
  def update
    respond_to do |format|
      if @movimentacao.update(movimentacao_params)
        format.html { redirect_to @movimentacao, notice: "Movimentação atualizada com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: @movimentacao }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movimentacao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movimentacaos/1 or /movimentacaos/1.json
  def destroy
    @movimentacao.destroy!

    respond_to do |format|
      format.html { redirect_to movimentacaos_path, notice: "Movimentação excluída com sucesso!", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movimentacao
      @movimentacao = Movimentacao.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def movimentacao_params
      params.expect(movimentacao: [ :produto_id, :origem, :destino, :quantidade, :funcionario_id ])
    end
end
