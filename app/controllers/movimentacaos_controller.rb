class MovimentacaosController < ApplicationController
  # 🌟 CORREÇÃO: Removidos edit, update e destroy que não existem no arquivo
  before_action :set_movimentacao, only: %i[ show ]

  def index
    # 🌟 CORREÇÃO: Removido o filtro .where(tipo_movimentacao: "ENTRADA") para trazer TUDO (Entradas e Saídas)
    @movimentacaos = Movimentacao.all.order(created_at: :desc)
  end

  def create
    id_pesquisa = movimentacao_params[:produto_id]
    
    if id_pesquisa.include?("-")
      tipo, id_real = id_pesquisa.split("-")
      item_alvo = tipo == "PRODUTO" ? Produto.find(id_real) : Insumo.find(id_real)
    else
      item_alvo = Produto.find(id_pesquisa)
    end

    @movimentacao = Auditoria.new(
      produto: item_alvo.nome,
      responsavel: current_funcionario.nome,
      unidade_id: movimentacao_params[:destino], 
      acao: "ENTRADA",
      qtd: movimentacao_params[:quantidade],
      data_hora: Time.current
    )

    respond_to do |format|
      if @movimentacao.save
        atualizar_estoque_real(@movimentacao)
        format.html { redirect_to movimentacaos_path, notice: "Entrada de estoque registrada e auditada com sucesso!" }
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
    target = Insumo.find_by(nome: mov.produto)
    target ||= Produto.find_by(nome: mov.produto)
    
    return unless target

    nome_unidade = mov.unidade&.nome&.downcase || ""

    coluna = case nome_unidade
             when /centro/ then :estoque_centro
             when /novo/   then :estoque_pavilhao_novo
             when /antigo/ then :estoque_pavilhao_antigo
             end

    if coluna && target.respond_to?(coluna)
      novo_valor = (target.send(coluna).to_f + mov.qtd.to_f).round(3)
      target.update_column(coluna, novo_valor)
    end
  end

  private

  def set_movimentacao
    # 🌟 CORREÇÃO DEFINITIVA: Mudado de Auditoria para Movimentacao
    @movimentacao = Movimentacao.find(params[:id])
  end

  def movimentacao_params
    params.require(:movimentacao).permit(:produto_id, :origem, :destino, :quantidade, :funcionario_id)
  end
end