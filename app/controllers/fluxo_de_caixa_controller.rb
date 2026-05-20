class FluxoDeCaixaController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin

  def index
    @periodo = params[:periodo] || 'mensal'
    @unidade = params[:unidade].presence # Resgata a unidade (ex: 'centro', 'pavilhao_novo')

    case @periodo
    when 'diario'
      @range = Time.current.beginning_of_day..Time.current
    when 'semanal'
      @range = 7.days.ago.beginning_of_day..Time.current
    when 'mensal'
      @range = 30.days.ago.beginning_of_day..Time.current
    when 'anual'
      @range = 1.year.ago.beginning_of_day..Time.current
    else
      @range = 30.days.ago.beginning_of_day..Time.current
    end

    # --- ESCOPO DINÂMICO POR UNIDADE ---
    # Começa filtrando pelo período de tempo
    pedidos_escopo = Pedido.where(created_at: @range)
    despesas_escopo = Despesa.where(pago: true, updated_at: @range)

    # Se o filtro de unidade foi selecionado, restringe o banco de dados
    if @unidade.present?
      pedidos_escopo = pedidos_escopo.where(unidade: @unidade)
      despesas_escopo = despesas_escopo.where(unidade: @unidade)
    end

    # 1. ENTRADAS: Soma os pedidos filtrados pelo escopo correto
    @total_entradas = pedidos_escopo.sum(:valor_total)

    # 2. SAÍDAS CALIBRADAS
    @total_saidas = despesas_escopo.sum(:valor)

    # 3. SALDO LÍQUIDO
    @saldo_liquido = @total_entradas - @total_saidas

    # Extra: Busca detalhada das tabelas limitada a 10 registros
    @pedidos_detalhados = pedidos_escopo.order(created_at: :desc).limit(10)
    @despesas_detalhadas = despesas_escopo.order(updated_at: :desc).limit(10)
  end

  private

  def verificar_admin
    redirect_to root_path, alert: "Acesso restrito à gerência." unless current_funcionario.admin?
  end
end