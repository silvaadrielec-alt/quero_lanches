class ComposicoesController < ApplicationController
  before_action :authenticate_funcionario!

  def gerenciar
    @produtos = Produto.where(categoria: "Venda").order(:nome)
    
    if params[:produto_id].present?
      @produto_selecionado = Produto.find(params[:produto_id])
      @composicoes = @produto_selecionado.composicoes.includes(:insumo)
    end

    @nova_composicao = Composicao.new
    @insumos_disponiveis = Insumo.order(:nome)
  end

  def create
    produto_id = params[:produto_id] || params[:composicao][:produto_id]
    @produto = Produto.find(produto_id)
    @composicao = @produto.composicoes.build(composicao_params)

    if @composicao.save
      redirect_to gerenciar_composicoes_path(produto_id: @produto.id), notice: 'Insumo adicionado com sucesso!'
    else
      # Captura o erro de validação (como ingrediente duplicado) e joga no alert
      erros = @composicao.errors.full_messages.join(", ")
      redirect_to gerenciar_composicoes_path(produto_id: @produto.id), alert: "Erro ao adicionar insumo: #{erros}"
    end
  end

  def destroy
    @composicao = Composicao.find(params[:id])
    produto_id = @composicao.produto_id
    @composicao.destroy
    
    # 🌟 CALIBRAÇÃO TURBO: Adicionado status :see_other para forçar o Turbo Drive 
    # a limpar o DOM e atualizar a tabela de forma instantânea sem congelar a tela
    redirect_to gerenciar_composicoes_path(produto_id: produto_id), notice: 'Insumo removido da receita.', status: :see_other
  end

  private

  def composicao_params
    params.require(:composicao).permit(:insumo_id, :quantidade, :unidade_medida_uso)
  end
end