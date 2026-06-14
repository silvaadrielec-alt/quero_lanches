class RelatorioFinanceiroController < ApplicationController
  before_action :authenticate_funcionario!

  def index
    @data_inicio = params[:data_inicio] ? Date.parse(params[:data_inicio]) : 30.days.ago.to_date
    @data_fim = params[:data_fim] ? Date.parse(params[:data_fim]) : Date.today

    # 1. Base da Query
    @movimentacoes = Movimentacao.where(created_at: @data_inicio.beginning_of_day..@data_fim.end_of_day)

    # 2. O FILTRO DE UNIDADE (Aqui está o ponto chave)
    if params[:unidade_id].present?
      @movimentacoes = @movimentacoes.where(unidade_id: params[:unidade_id])
    end

    # 3. Ordenação e Otimização (O .includes(:unidade) evita o problema de N+1)
    @movimentacoes = @movimentacoes.order(created_at: :desc)
                                   .includes(:produto, :insumo, :unidade)

    # 4. Totais (Isso já vai funcionar perfeitamente com o filtro acima)
    @total_custo = @movimentacoes.sum(&:valor_custo)
    @total_receita = @movimentacoes.sum(&:valor_receita)
    @lucro_bruto = @total_receita - @total_custo
  end
end