class FaturamentosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    @periodo = params[:periodo] || 'semanal'
    
    case @periodo
    when 'diario'
      @range = Time.current.beginning_of_day..Time.current
      @granularidade = :hour
    when 'semanal'
      @range = 7.days.ago.beginning_of_day..Time.current
      @granularidade = :day
    when 'mensal'
      @range = 30.days.ago.beginning_of_day..Time.current
      @granularidade = :day
    when 'anual'
      @range = 1.year.ago.beginning_of_day..Time.current
      @granularidade = :month
    else
      @range = 7.days.ago.beginning_of_day..Time.current
      @granularidade = :day
    end

    # Definição clara para cada gráfico
    titulos = { 'diario' => 'Tendência Diária', 'semanal' => 'Tendência Semanal', 'mensal' => 'Tendência Mensal', 'anual' => 'Tendência Anual' }
    @titulo_evolucao = "Evolução de Vendas (#{titulos[@periodo].split(' ').last})"
    @titulo_tendencia = titulos[@periodo] || 'Tendência de Vendas'

    # Evolução Geral: Agrupamento dinâmico
    agrupamento_geral = ['mensal', 'anual'].include?(@periodo) ? :week : @granularidade
    @vendas_geral_diaria = Pedido.where(created_at: @range)
                                 .group_by_period(agrupamento_geral, :created_at)
                                 .sum(:valor_total)

    # Vendas por Unidade
    @vendas_por_unidade = {
      "Centro" => Pedido.where(unidade_id: 1, created_at: @range).sum(:valor_total),
      "Pavilhão Novo" => Pedido.where(unidade_id: 2, created_at: @range).sum(:valor_total),
      "Pavilhão Antigo" => Pedido.where(unidade_id: 3, created_at: @range).sum(:valor_total)
    }

    # Tendência Mensal
    @vendas_unidades_mensal = Pedido.where(created_at: @range)
                                    .group_by_period(:month, :created_at)
                                    .sum(:valor_total)
    
    # Comparativo
    intervalo_comp = ['mensal', 'anual'].include?(@periodo) ? :week : :day
    @vendas_unidades_comparativo = Pedido.where(created_at: @range)
                                         .joins(:unidade) # Garante que a unidade existe
                                         .group("unidades.nome")
                                         .group_by_period(intervalo_comp, :created_at)
                                         .sum(:valor_total)

    # 4. Ranking de Produtos (Corrigido para evitar conflitos de objeto)
    produtos_ids = ItemPedido.joins(:pedido)
                             .where(pedidos: { created_at: @range })
                             .group(:produto_id)
                             .sum(:quantidade) # Retorna um hash {produto_id => total}
    
    # Transformamos o hash {id => total} em uma lista de objetos Produto decorados
    @itens_mais_vendidos = produtos_ids.map do |id, total|
      produto = Produto.find(id)
      produto.define_singleton_method(:total_vendido) { total }
      produto
    end.sort_by(&:total_vendido).reverse.first(5)

    # 5. Ranking de Funcionários (Corrigido da mesma forma)
    func_vendas = Pedido.where(created_at: @range)
                        .group(:funcionario_id)
                        .sum(:valor_total)
    
    @ranking_funcionarios = func_vendas.map do |id, total|
      func = Funcionario.find(id)
      func.define_singleton_method(:total_vendas) { total }
      func
    end.sort_by(&:total_vendas).reverse.first(5)

    @ranking_funcionarios = Funcionario.joins(:pedidos)
                                       .where(pedidos: { created_at: @range })
                                       .group('funcionarios.id')
                                       .select('funcionarios.*, SUM(pedidos.valor_total) as total_vendas')
                                       .order('total_vendas DESC')
                                       .limit(5)

    @total_geral = @vendas_por_unidade.values.sum
  end

  def exportar
    data_inicial = case params[:periodo]
                   when 'diario' then Time.current.beginning_of_day
                   when 'semanal' then 7.days.ago.beginning_of_day
                   when 'mensal' then 30.days.ago.beginning_of_day
                   else 30.days.ago.beginning_of_day
                   end
    @pedidos = Pedido.where("created_at >= ?", data_inicial).order(created_at: :desc)
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(col_sep: ';', force_quotes: true) do |csv|
          csv << ["ID Pedido", "Data", "Unidade", "Total R$", "Funcionario"]
          @pedidos.each { |p| csv << [p.id, p.created_at.strftime("%d/%m/%y %H:%M"), p.unidade&.nome&.upcase, '%.2f' % p.valor_total, p.funcionario&.nome] }
        end
        send_data "\xEF\xBB\xBF" + csv_data, filename: "Faturamento_#{Date.today}.csv", type: 'text/csv'
      end
    end
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito." unless current_funcionario&.admin?
  end
end