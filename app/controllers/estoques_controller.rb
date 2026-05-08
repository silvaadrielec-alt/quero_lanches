class EstoquesController < ApplicationController
  # Somente admins podem gerenciar o estoque geral
  before_action :set_produto, only: [:edit, :update]

 def index
  # Filtra os produtos em duas listas separadas para a View
  @produtos_venda = Produto.where(categoria: "Venda")
  @insumos = Produto.where(categoria: "Insumo")
end

  def edit
    # Abre a tela de edição de quantidade
  end

  def update
    if @produto.update(estoque_params)
      redirect_to estoques_path, notice: "Quantidades do estoque atualizadas com sucesso!"
    else
      render :edit
    end
  end

  def repor
  @produto = Produto.find(params[:produto_id])
  quantidade_adicional = params[:quantidade].to_f
  unidade = params[:unidade]

  if quantidade_adicional > 0
    # Somamos APENAS na unidade escolhida no seletor
    case unidade
    when 'centro'
      @produto.increment!(:estoque_centro, quantidade_adicional)
    when 'pavilhao_novo'
      @produto.increment!(:estoque_pavilhao_novo, quantidade_adicional)
    when 'pavilhao_antigo'
      @produto.increment!(:estoque_pavilhao_antigo, quantidade_adicional)
    end

    # Criação do Log de Auditoria para o Painel
    Movimentacao.create!(
      produto: @produto,
      funcionario: current_funcionario,
      quantidade: quantidade_adicional,
      tipo_movimentacao: 'entrada',
      unidade: unidade.upcase.gsub('_', ' ')
    )

    flash[:notice] = "Estoque de #{@produto.nome} abastecido com +#{quantidade_adicional} no #{unidade.upcase}!"
  else
    flash[:alert] = "Insira uma quantidade válida."
  end

  redirect_to estoques_path
end

def auditoria
  @movimentacoes = Movimentacao.all.order(created_at: :desc)
end

  private

  def set_produto
    @produto = Produto.find(params[:id])
  end

  def estoque_params
    # SEGURANÇA: Permitimos APENAS os campos de quantidade aqui
    params.require(:produto).permit(:estoque_centro, :estoque_pavilhao_novo, :estoque_pavilhao_antigo)
  end
end
