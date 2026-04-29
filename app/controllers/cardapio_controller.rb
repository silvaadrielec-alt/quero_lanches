class CardapioController < ApplicationController

  before_action :verificar_admin, except: [:index, :show]

  def index
    @produtos = Produto.where(categoria: 'Venda')
  end

  def new
    @produto = Produto.new(categoria: 'Venda')
  end

  def create
  @produto = Produto.new(produto_params)
  @produto.categoria = 'Venda'
  
  # GARANTIA: Se o campo estiver vazio no formulário, ele salva como 0
  @produto.estoque_centro ||= 0
  @produto.estoque_pavilhao_novo ||= 0
  @produto.estoque_pavilhao_antigo ||= 0
  @produto.preco_venda ||= 0
  @produto.unidade_medida ||= 'unidade'

  if @produto.save
    redirect_to cardapio_index_path, notice: 'Lanche cadastrado com sucesso!'
  else
    # Se der erro, isso vai mostrar no terminal o porquê
    puts @produto.errors.full_messages 
    render :new, status: :unprocessable_entity
  end
end

  def edit
    @produto = Produto.find(params[:id])
  end

  def update
    @produto = Produto.find(params[:id])
    if @produto.update(produto_params)
      redirect_to cardapio_index_path, notice: 'Lanche atualizado!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @produto = Produto.find(params[:id])
    @produto.destroy
    redirect_to cardapio_index_path, notice: 'Removido com sucesso!'
  end

  def show
    @produto = Produto.find(params[:id])
  end

  private # <-- Tudo abaixo daqui é "protegido"

  def verificar_admin
    unless current_funcionario.admin?
      redirect_to cardapio_index_path, alert: "Acesso negado! Apenas administradores podem alterar o cardápio."
    end
  end

  def produto_params
    params.require(:produto).permit(:nome, :preco_venda, :valor_unitario, :quantidade, :categoria, :unidade_medida, :estoque_centro, :estoque_pavilhao_novo, :estoque_pavilhao_antigo)
  end
end