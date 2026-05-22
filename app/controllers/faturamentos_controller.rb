require 'csv'

class FaturamentosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    # Define o período com base no parâmetro da URL
    @periodo = params[:periodo] || 'semanal'
    
    case @periodo
    when 'diario'
      @range = Time.current.beginning_of_day..Time.current
      # Agrupamento nativo por hora formatada (ex: "14:00")
      @formato_data = "strftime('%H:00', created_at)"
    when 'semanal'
      @range = 7.days.ago.beginning_of_day..Time.current
      # Agrupamento nativo por data pura (ex: "19/05/2026")
      @formato_data = "strftime('%d/%m/%Y', created_at)"
    when 'mensal'
      @range = 30.days.ago.beginning_of_day..Time.current
      @formato_data = "strftime('%d/%m/%Y', created_at)"
    when 'anual'
      @range = 1.year.ago.beginning_of_day..Time.current
      # Agrupamento nativo por mês (ex: "05/2026")
      @formato_data = "strftime('%m/%Y', created_at)"
    else
      @range = 7.days.ago.beginning_of_day..Time.current
      @formato_data = "strftime('%d/%m/%Y', created_at)"
    end

    # 1. Evolução Geral (Calculado de forma pura pelo SQLite, sem Groupdate)
    @vendas_geral_diaria = Pedido.where(created_at: @range)
                                 .group(@formato_data)
                                 .sum(:valor_total)

    # 2. Vendas por Unidade (Totais do período selecionado)
    @vendas_por_unidade = {
      "Matriz Centro" => Pedido.where(unidade: 'centro', created_at: @range).sum(:valor_total),
      "Pavilhão Novo" => Pedido.where(unidade: 'pavilhao_novo', created_at: @range).sum(:valor_total),
      "Pavilhão Antigo" => Pedido.where(unidade: 'pavilhao_antigo', created_at: @range).sum(:valor_total)
    }

    # 3. Evolução Comparativa entre Unidades (Nativo)
    @vendas_unidades_comparativo = [
      { name: "Matriz", data: Pedido.where(unidade: 'centro', created_at: @range).group(@formato_data).sum(:valor_total) },
      { name: "Pav. Novo", data: Pedido.where(unidade: 'pavilhao_novo', created_at: @range).group(@formato_data).sum(:valor_total) },
      { name: "Pav. Antigo", data: Pedido.where(unidade: 'pavilhao_antigo', created_at: @range).group(@formato_data).sum(:valor_total) }
    ]
    
    # 4. Desempenho Mensal (Nativo por mês nos últimos 12 meses)
    formato_mensal = "strftime('%m/%Y', created_at)"
    @vendas_unidades_mensal = [
      { name: "Matriz", data: Pedido.where(unidade: 'centro').where("created_at >= ?", 12.months.ago).group(formato_mensal).sum(:valor_total) },
      { name: "Pav. Novo", data: Pedido.where(unidade: 'pavilhao_novo').where("created_at >= ?", 12.months.ago).group(formato_mensal).sum(:valor_total) },
      { name: "Pav. Antigo", data: Pedido.where(unidade: 'pavilhao_antigo').where("created_at >= ?", 12.months.ago).group(formato_mensal).sum(:valor_total) }
    ]

    # AJUSTADO AQUI: Agora faz o join cruzando o carrinho para somar as quantidades dos itens
    @itens_mais_vendidos = Pedido.where(created_at: @range)
                                 .joins(item_pedidos: :produto)
                                 .group('produtos.nome')
                                 .sum('item_pedidos.quantidade')
                                 .sort_by { |_nome, qtd| -qtd }
                                 .first(5)

    # Variáveis para os Cards de valor
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
               " " + pedido.created_at.strftime("%d/%m/%y %H:%M"), 
               pedido.unidade&.upcase,
               format("%.2f", pedido.valor_total).gsub('.', ','),
               pedido.funcionario&.nome || "Sistema"
             ]
          end
        end

        send_data "\xEF\xBB\xBF" + csv_data, filename: filename, type: 'text/csv; charset=utf-8'
      end
    end
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência." unless current_funcionario.admin?
  end
end