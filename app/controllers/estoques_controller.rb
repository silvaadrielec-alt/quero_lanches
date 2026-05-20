class EstoquesController < ApplicationController
  before_action :set_produto, only: [:edit, :update]

  def index
    @produtos_venda = Produto.where(categoria: "Venda")
    @insumos = Produto.where(categoria: "Insumo")
  end

  # NOVO: Abre a página de Nova Entrada por Lote
  def lote
    @produtos = Produto.order(:nome) # Carrega todos os produtos para os selects
  end

  # NOVO: Processa a lista inteira enviada pela tela
  def processar_lote
    unidade = params[:unidade]
    itens = params[:itens] # Recebe o array de produtos e quantidades

    if unidade.blank?
      flash[:alert] = "Por favor, selecione a unidade de destino."
      redirect_to lote_estoques_path and return
    end

    if itens.blank? || itens.values.all? { |i| i[:produto_id].blank? || i[:quantidade].to_f <= 0 }
      flash[:alert] = "Adicione pelo menos um produto com quantidade válida."
      redirect_to lote_estoques_path and return
    end

    contador_sucesso = 0

    # Abre uma transação no banco: ou salva tudo certo, ou não salva nada se der erro
    ActiveRecord::Base.transaction do
      itens.each_value do |item|
        produto_id = item[:produto_id]
        quantidade = item[:quantidade].to_f

        next if produto_id.blank? || quantidade <= 0

        produto = Produto.find(produto_id)

        # Atualiza a quantidade na unidade correspondente
        case unidade
        when 'centro'
          produto.increment!(:estoque_centro, quantidade)
        when 'pavilhao_novo'
          produto.increment!(:estoque_pavilhao_novo, quantidade)
        when 'pavilhao_antigo'
          produto.increment!(:estoque_pavilhao_antigo, quantidade)
        end

        # Cria o log na tabela que você já possui
        Movimentacao.create!(
          produto: produto,
          funcionario: current_funcionario,
          quantidade: quantidade,
          tipo_movimentacao: 'entrada',
          unidade: unidade.upcase.gsub('_', ' ')
        )

        contador_sucesso += 1
      end
    end

    flash[:notice] = "Sucesso! Foram repostos #{contador_sucesso} itens no estoque do(a) #{unidade.upcase.gsub('_', ' ')}."
    redirect_to estoques_path
  rescue => e
    flash[:alert] = "Ocorreu um erro ao processar o lote: #{e.message}"
    redirect_to lote_estoques_path
  end

  def edit
  end

  def update
    if @produto.update(estoque_params)
      redirect_to estoques_path, notice: "Quantidades do estoque updated com sucesso!"
    else
      render :edit
    end
  end

  # Mantemos o repor antigo caso alguma outra tela ainda use ele de forma isolada
  def repor
    @produto = Produto.find(params[:produto_id])
    quantidade_adicional = params[:quantidade].to_f
    unidade = params[:unidade]

    if quantidade_adicional > 0
      case unidade
      when 'centro'
        @produto.increment!(:estoque_centro, quantidade_adicional)
      when 'pavilhao_novo'
        @produto.increment!(:estoque_pavilhao_novo, quantidade_adicional)
      when 'pavilhao_antigo'
        @produto.increment!(:estoque_pavilhao_antigo, quantidade_adicional)
      end

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
    params.require(:produto).permit(:estoque_centro, :estoque_pavilhao_novo, :estoque_pavilhao_antigo)
  end
end