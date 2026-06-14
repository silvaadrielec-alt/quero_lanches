class CardapioController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin, except: [:index, :show]

  # Lista todos os lanches disponíveis para venda
  def index
    @produtos = Produto.where(categoria: 'Venda').order(:nome)
  end

  def show
    @produto = Produto.find(params[:id])
  end

  # No seu app/controllers/cardapio_controller.rb
def new
  @produto = Produto.new(categoria: 'Venda', estoque_controlado: false)
end

  def create
    @produto = Produto.new(produto_params)
    @produto.categoria = 'Venda' # Força a categoria para aparecer no PDV

    if @produto.save
      redirect_to cardapio_index_path, notice: 'Lanche cadastrado no cardápio com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @produto = Produto.find(params[:id])
  end

  def update
    @produto = Produto.find(params[:id])
    if @produto.update(produto_params)
      redirect_to cardapio_index_path, notice: 'Lanche atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @produto = Produto.find(params[:id])
    
    # Impede a exclusão se o lanche já foi vendido antes, protegendo o banco
    if @produto.destroy
      redirect_to cardapio_index_path, notice: 'Lanche removido do cardápio.'
    else
      redirect_to cardapio_index_path, alert: 'Não é possível remover: este lanche possui histórico de vendas.'
    end
  end

  private

  def verificar_admin
    unless current_funcionario.admin?
      redirect_to cardapio_index_path, alert: "Acesso negado! Apenas administradores alteram o cardápio."
    end
  end

  # Permite apenas os dados comerciais e de identificação do lanche
  def produto_params
    params.require(:produto).permit(:nome, :preco_venda, :codigo, :unidade_medida, :aceita_adicional, :custo_producao, :estoque_controlado, :categoria)
  end
end