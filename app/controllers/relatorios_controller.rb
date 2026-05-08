class RelatoriosController < ApplicationController
  before_action :authenticate_funcionario!
  require 'csv'

  def index
    @produtos_para_comprar = Produto.all.select(&:precisa_reposicao?)
    
    # Resumo Financeiro
    @total_vendas = Pedido.sum(:valor_total)
    @total_despesas = Despesa.where(pago: true).sum(:valor)
    @lucro_liquido = @total_vendas - @total_despesas
  end

  def auditoria
    # Agora usando o nome correto do seu arquivo: Movimentacao
    @movimentacoes = Movimentacao.all.order(created_at: :desc)
  end

  def exportar_auditoria
    @movimentacoes = Movimentacao.all.order(created_at: :desc)
    
    respond_to do |format|
      format.csv do
        filename = "Auditoria_CantinaTech_#{Date.today}.csv"
        csv_data = CSV.generate(col_sep: ';', force_quotes: true) do |csv|
          csv << ["Data/Hora", "Responsável", "Unidade", "Item", "Ação", "Quantidade"]
          
          @movimentacoes.each do |log|
            csv << [
              log.created_at.strftime("%d/%m/%y %H:%M"),
              log.respond_to?(:responsavel) ? log.responsavel : log.funcionario&.nome,
              log.unidade&.upcase,
              log.respond_to?(:produto_nome) ? log.produto_nome : log.produto&.nome,
              log.respond_to?(:acao) ? log.acao : log.tipo_movimentacao,
              log.respond_to?(:qtd) ? log.qtd : log.quantidade
            ]
          end
        end
        send_data "\xEF\xBB\xBF" + csv_data, filename: filename, type: 'text/csv; charset=utf-8'
      end
    end
  end
end