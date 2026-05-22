class ComposicoesController < ApplicationController
  # NOVO: Abre a página centralizada de Gerenciamento de Fichas Técnicas
  def gerenciar
    @produtos = Produto.where(categoria: "Venda").order(:nome)
    
    # Se o usuário escolheu um produto no select da tela, carrega as composições dele
    if params[:produto_id].present?
      @produto_selecionado = Produto.find(params[:produto_id])
      @composicoes = @produto_selecionado.composicoes.includes(:insumo)
    end

    # Prepara os objetos necessários para alimentar o formulário de adição da nova linha
    @nova_composicao = Composicao.new
    @insumos_disponiveis = Produto.where(categoria: "Insumo").order(:nome)
  end

  # ATUALIZADO: Salva o insumo na receita e mantém o usuário na tela centralizada
  def create
    # Se o parâmetro vier do formulário aninhado antigo ou novo, garante a captura do produto_id
    produto_id = params[:produto_id] || params[:composicao][:produto_id]
    @produto = Produto.find(produto_id)
    @composicao = @produto.composicoes.build(composicao_params)

    if @composicao.save
      redirect_to gerenciar_composicoes_path(produto_id: @produto.id), notice: 'Insumo adicionado com sucesso!'
    else
      redirect_to gerenciar_composicoes_path(produto_id: @produto.id), alert: 'Erro ao adicionar insumo. Verifique os dados.'
    end
  end

  # ATUALIZADO: Remove o insumo da receita e mantém o usuário na tela centralizada
  def destroy
    @composicao = Composicao.find(params[:id])
    produto_id = @composicao.produto_id
    @composicao.destroy
    
    redirect_to gerenciar_composicoes_path(produto_id: produto_id), notice: 'Insumo removido da receita.'
  end

  private

  def composicao_params
    params.require(:composicao).permit(:insumo_id, :quantidade, :unidade_medida_uso)
  end
end
