class RelatorioFinanceiroController < ApplicationController
  before_action :authenticate_funcionario!

  def index
    @data_inicio = params[:data_inicio] ? Date.parse(params[:data_inicio]) : 30.days.ago.to_date
    @data_fim = params[:data_fim] ? Date.parse(params[:data_fim]) : Date.today

    # 1. Base da Query: Todas as movimentações do período
    @movimentacoes = Movimentacao.where(created_at: @data_inicio.beginning_of_day..@data_fim.end_of_day)

    if params[:unidade_id].present?
      @movimentacoes = @movimentacoes.where(unidade_id: params[:unidade_id])
    end

    # 2. Ordenação
    @movimentacoes = @movimentacoes.order(created_at: :desc).includes(:produto, :insumo, :unidade)

    # 3. Filtragem para os Cards (Lucro/Custo/Receita)
    # A variável 'saidas' garante que apenas o que foi vendido/saído seja contabilizado no resultado
    saidas = @movimentacoes.where("tipo_movimentacao LIKE ?", "%saida%")

    # Os cards somam apenas as movimentações que são SAÍDAS
    @total_custo = saidas.sum(:valor_custo)
    @total_receita = saidas.sum(:valor_receita)
    
    # Soma de transferências (para fins de controle patrimonial)
    @total_transferencias = @movimentacoes.where(tipo_movimentacao: 'saida_transferencia').sum(:valor_custo)
    
    # Lucro Bruto: Receita de vendas menos o custo do que foi vendido
    @lucro_bruto = @total_receita - @total_custo
  end
end