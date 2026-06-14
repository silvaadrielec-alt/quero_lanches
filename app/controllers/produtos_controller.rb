class ProdutosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin, only: [:destroy, :edit, :update]
  before_action :set_produto, only: %i[ show edit update destroy ]

  def index
    if params[:query].present?
      termo = "%#{params[:query].downcase}%"
      base = Produto.where("lower(nome) LIKE ?", termo)
    else
      base = Produto.all
    end

    # Traz apenas os itens destinados ao cardápio de vendas direto
    @produtos_venda = base.where(categoria: "Venda")
  end

  def show
    @produto = Produto.find(params[:id])
    
    respond_to do |format|
      format.html 
      format.json { 
        render json: @produto.as_json(include: { composicoes: { include: :insumo } }) 
      }
    end
  end

  def new
    @produto = Produto.new
  end

  def edit
  end

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

  def update
    if @produto.update(produto_params)
      redirect_to produtos_path, notice: "Produto atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Trata de forma segura o impedimento de remoção caso haja vendas vinculadas
    if @produto.destroy
      flash[:notice] = "Produto excluído com sucesso!"
    else
      flash[:alert] = "Não é possível excluir: este produto possui registros de vendas ativos no histórico contábil."
    end

    respond_to do |format|
      format.html { redirect_to produtos_path, status: :see_other } # Corrigido rota fantasma
      format.json { head :no_content }
    end
  end

  private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def produto_params
    params.require(:produto).permit(
      :nome, :preco_venda, :categoria, :unidade_medida, :valor_unitario,
      :codigo, :aceita_adicional,
      :limite_centro, :limite_pavilhao_novo, :limite_pavilhao_antigo, # Incluídos para o controle de alertas mínimos
      variacao_produtos_attributes: [:id, :tamanho, :preco_venda, :_destroy]
    )
  end

  def verificar_admin
    unless current_funcionario.admin?
      redirect_to root_path, alert: "Acesso negado! Você não tem permissão de Administrador."
    end
  end
end