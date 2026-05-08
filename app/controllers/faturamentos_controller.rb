require 'csv'

class FaturamentosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    # Define o período e o tipo de agrupamento com base no parâmetro da URL
    @periodo = params[:periodo] || 'semanal'
    
    case @periodo
    when 'diario'
      @range = Time.current.beginning_of_day..Time.current
      @agrupamento = :group_by_hour # Mostra a evolução por hora se for só hoje
    when 'semanal'
      @range = 7.days.ago.beginning_of_day..Time.current
      @agrupamento = :group_by_day
    when 'mensal'
      @range = 30.days.ago.beginning_of_day..Time.current
      @agrupamento = :group_by_day
    when 'anual'
      @range = 1.year.ago.beginning_of_day..Time.current
      @agrupamento = :group_by_month # Agrupa por mês para o gráfico anual ficar limpo
    else
      @range = 7.days.ago.beginning_of_day..Time.current
      @agrupamento = :group_by_day
    end

    # 1. Evolução Geral (Respeitando o filtro selecionado)
    @vendas_geral_diaria = Pedido.where(created_at: @range).send(@agrupamento, :created_at).sum(:valor_total)

    # 2. Vendas por Unidade (Totais do período selecionado)
    @vendas_por_unidade = {
      "Matriz Centro" => Pedido.where(unidade: 'centro', created_at: @range).sum(:valor_total),
      "Pavilhão Novo" => Pedido.where(unidade: 'pavilhao_novo', created_at: @range).sum(:valor_total),
      "Pavilhão Antigo" => Pedido.where(unidade: 'pavilhao_antigo', created_at: @range).sum(:valor_total)
    }

    # 3. Evolução Comparativa entre Unidades
    @vendas_unidades_comparativo = [
      { name: "Matriz", data: Pedido.where(unidade: 'centro', created_at: @range).send(@agrupamento, :created_at).sum(:valor_total) },
      { name: "Pav. Novo", data: Pedido.where(unidade: 'pavilhao_novo', created_at: @range).send(@agrupamento, :created_at).sum(:valor_total) },
      { name: "Pav. Antigo", data: Pedido.where(unidade: 'pavilhao_antigo', created_at: @range).send(@agrupamento, :created_at).sum(:valor_total) }
    ]
    
     # Garante que os dados para o gráfico de desempenho mensal (Anual) sempre existam
     @vendas_unidades_mensal = [
      { name: "Matriz", data: Pedido.where(unidade: 'centro').group_by_month(:created_at, last: 12).sum(:valor_total) },
      { name: "Pav. Novo", data: Pedido.where(unidade: 'pavilhao_novo').group_by_month(:created_at, last: 12).sum(:valor_total) },
      { name: "Pav. Antigo", data: Pedido.where(unidade: 'pavilhao_antigo').group_by_month(:created_at, last: 12).sum(:valor_total) }
    ]

      # No FaturamentosController, substitua o bloco do Top 5 (linhas 53 a 59) por este:

      @itens_mais_vendidos = Pedido.where(created_at: @range)
                             .joins(:produto) # Garante que temos acesso ao nome do produto
                             .group('produtos.nome') # Agrupa pelo nome real do item
                             .sum(:quantidade) # Soma as quantidades vendidas
                             .sort_by { |_nome, qtd| -qtd } # Ordena do maior para o menor
                             .first(5) # Pega os 5 melhores

    # Variáveis para os Cards de valor (Cantina Quero Lanches)
    @total_geral = @vendas_por_unidade.values.sum
    @vendas_matriz = @vendas_por_unidade["Matriz Centro"]
    @vendas_pavilhao_novo = @vendas_por_unidade["Pavilhão Novo"]
    @vendas_pavilhao_antigo = @vendas_por_unidade["Pavilhão Antigo"]
  end

def exportar
  @periodo = params[:periodo] || 'mensal'
  
  data_inicial = case @periodo
                 when 'diario'  then Time.current.beginning_of_day
                 when 'semanal' then 7.days.ago.beginning_of_day
                 when 'mensal'  then 30.days.ago.beginning_of_day
                 when 'anual'   then 1.year.ago.beginning_of_day
                 else 30.days.ago.beginning_of_day
                 end

  @pedidos = Pedido.where("created_at >= ?", data_inicial).order(created_at: :desc)

  respond_to do |format|
    format.csv do
      filename = "QueroLanches_Faturamento_#{@periodo}_#{Date.today}.csv"
      
      csv_data = CSV.generate(col_sep: ';', force_quotes: true) do |csv|
        csv << ["ID Pedido", "Data e Hora", "Unidade", "Total (R$)", "Funcionario"]
        
        @pedidos.each do |pedido|
           csv << [
             pedido.id,
            # Adicionamos um espaço no início para o Excel não formatar automaticamente
            " " + pedido.created_at.strftime("%d/%m/%y %H:%M"), 
             pedido.unidade&.upcase,
            format("%.2f", pedido.valor_total).gsub('.', ','),
            pedido.funcionario&.nome || "Sistema"
            ]
        end
      end

      # O \xEF\xBB\xBF é o "segredo" para o Excel abrir com a codificação certa
      send_data "\xEF\xBB\xBF" + csv_data, filename: filename, type: 'text/csv; charset=utf-8'
    end
  end
end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência." unless current_funcionario.admin?
  end
end