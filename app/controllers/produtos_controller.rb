class ProdutosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin, only: [:destroy, :edit, :update] # Protege ações críticas
  before_action :set_produto, only: %i[ show edit update destroy ]

  # GET /produtos or /produtos.json
  def index
    @produtos = Produto.all
  end

  # GET /produtos/1 or /produtos/1.json
  def show
  end

  # GET /produtos/new
  def new
    @produto = Produto.new
  end

  # GET /produtos/1/edit
  def edit
  end

  # POST /produtos or /produtos.json
  def create
    @produto = Produto.new(produto_params)

    respond_to do |format|
      if @produto.save
        format.html { redirect_to @produto, notice: "Produto cadastrado com sucesso!" }
        format.json { render :show, status: :created, location: @produto }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @produto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /produtos/1 or /produtos/1.json
  def update
    respond_to do |format|
      if @produto.update(produto_params)
        format.html { redirect_to @produto, notice: "Produto atualizado com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: @produto }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @produto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /produtos/1 or /produtos/1.json
  def destroy
    @produto.destroy!

    respond_to do |format|
      format.html { redirect_to produtos_path, notice: "Produto excluído com sucesso!", status: :see_other }
      format.json { head :no_content }
    end
  end

private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(:nome, :valor_unitario, :estoque_centro, :estoque_pavilhao_novo, :estoque_pavilhao_antigo)
  end

  # Adicione o método aqui, antes do último 'end'
  def verificar_admin
    unless current_funcionario.admin?
      redirect_to root_path, alert: "Acesso negado! Você não tem permissão de Administrador."
    end
  end
end
