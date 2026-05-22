class MovimentacaosController < ApplicationController
  before_action :set_movimentacao, only: %i[ show edit update destroy ]

  def index
    # Aqui buscamos de Auditoria para mostrar as entradas manuais no painel geral
    @movimentacaos = Auditoria.where(acao: "ENTRADA").order(created_at: :desc)
  end

  def create
    # Quando a Rosa cadastrar uma entrada manual, criamos um registro em Auditoria
    @movimentacao = Auditoria.new(
      produto: Produto.find(movimentacao_params[:produto_id]).nome,
      responsavel: current_funcionario.nome,
      unidade: movimentacao_params[:destino], # Onde o produto está entrando
      acao: "ENTRADA",
      qtd: movimentacao_params[:quantidade],
      data_hora: Time.current
    )

    respond_to do |format|
      if @movimentacao.save
        # Além de salvar o log, precisamos aumentar o estoque real do produto!
        atualizar_estoque_real(@movimentacao)
        
        format.html { redirect_to relatorios_auditoria_path, notice: "Entrada de estoque registrada e auditada!" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  # Método auxiliar para somar no estoque quando for entrada manual
  def atualizar_estoque_real(mov)
    produto = Produto.find_by(nome: mov.produto)
    return unless produto

    case mov.unidade.downcase
    when /centro/ then produto.increment!(:estoque_centro, mov.qtd)
    when /novo/   then produto.increment!(:estoque_pavilhao_novo, mov.qtd)
    when /antigo/ then produto.increment!(:estoque_pavilhao_antigo, mov.qtd)
    end
  end

  def set_movimentacao
    @movimentacao = Auditoria.find(params[:id])
  end

  def movimentacao_params
    # Ajustei para os campos que vêm do seu formulário de movimentação
    params.require(:movimentacao).permit(:produto_id, :origem, :destino, :quantidade, :funcionario_id)
  end
end