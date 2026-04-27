class ComposicoesController < ApplicationController
  # Método para salvar o insumo na receita
  def create
    @produto = Produto.find(params[:produto_id])
    @composicao = @produto.composicoes.build(composicao_params)

    if @composicao.save
      redirect_to @produto, notice: 'Insumo adicionado com sucesso!'
    else
      redirect_to @produto, alert: 'Erro ao adicionar insumo. Verifique os dados.'
    end
  end

  # Método para remover o insumo da receita
  def destroy
    @composicao = Composicao.find(params[:id])
    @produto = @composicao.produto
    @composicao.destroy
    redirect_to @produto, notice: 'Insumo removido da receita.'
  end

  private

  def composicao_params
    params.require(:composicao).permit(:insumo_id, :quantidade, :unidade_medida_uso)
  end
end
