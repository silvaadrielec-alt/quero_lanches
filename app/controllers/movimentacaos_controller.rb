class MovimentacaosController < ApplicationController
  # 🌟 CORREÇÃO: Removidos edit, update e destroy que não existem no arquivo
  before_action :set_movimentacao, only: %i[ show ]

  def index
    # 🌟 CORREÇÃO: Removido o filtro .where(tipo_movimentacao: "ENTRADA") para trazer TUDO (Entradas e Saídas)
    @movimentacaos = Movimentacao.all.order(created_at: :desc)
  end

 def create
  # Lógica de identificação do item
  id_pesquisa = movimentacao_params[:produto_id]
  item_alvo = nil

  if id_pesquisa.include?("-")
    tipo, id_real = id_pesquisa.split("-")
    item_alvo = tipo == "PRODUTO" ? Produto.find(id_real) : Insumo.find(id_real)
  else
    item_alvo = Produto.find(id_pesquisa)
  end

  # Instancia a Movimentacao com os params
  @movimentacao = Movimentacao.new(movimentacao_params)
  
  # Associações diretas
  @movimentacao.produto = item_alvo if item_alvo.is_a?(Produto)
  @movimentacao.insumo = item_alvo if item_alvo.is_a?(Insumo)
  @movimentacao.funcionario = current_funcionario

  respond_to do |format|
    if @movimentacao.save
      atualizar_estoque_real(@movimentacao)
      format.html { redirect_to movimentacaos_path, notice: "Movimentação e Auditoria registradas com sucesso!" }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end

  def show
    # Ação show estruturada para renderizar os detalhes de uma auditoria específica
  end

  private

  def atualizar_estoque_real(mov)
  target = mov.produto || mov.insumo
  
  return unless target

    nome_unidade = mov.unidade&.nome&.downcase || ""

    coluna = case nome_unidade
             when /centro/ then :estoque_centro
             when /novo/   then :estoque_pavilhao_novo
             when /antigo/ then :estoque_pavilhao_antigo
             end

    if coluna && target.respond_to?(coluna)
      novo_valor = (target.send(coluna).to_f + mov.quantidade.to_f).round(3)
      target.update_column(coluna, novo_valor)
    end
  end

  private

  def set_movimentacao
    # 🌟 CORREÇÃO DEFINITIVA: Mudado de Auditoria para Movimentacao
    @movimentacao = Movimentacao.find(params[:id])
  end

  def movimentacao_params
    params.require(:movimentacao).permit(:produto_id, :origem, :destino, :quantidade, :funcionario_id, :tipo_movimentacao, :unidade_id)
  end
end