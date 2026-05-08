class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show edit update destroy comprovante ]

  def index
    @pedidos = Pedido.all
  end

  def show
  end

  # NOVO MÉTODO: Gera o cupom sem o layout do site
  def comprovante
    render layout: false
  end

  def new
    @pedido = Pedido.new
  end

  def edit
  end

  def create
  @pedido = Pedido.new(pedido_params)
  @pedido.funcionario = current_funcionario
  @produto = Produto.find_by(id: pedido_params[:produto_id])

  # Lógica do Fator de Tamanho
  fator = case @pedido.tamanho
          when "Copo 200ml" then 0.2
          when "Copo 300ml" then 0.3
          when "Copo 500ml" then 0.5
          when "Jarra 1L"    then 1.0
          else 1.0
          end

  if @produto
    qtd_informada = pedido_params[:quantidade].to_f > 0 ? pedido_params[:quantidade].to_f : 1.0
    preco_base = @produto.preco_venda.to_f 
    
    # Calculamos os valores antes de salvar
    @pedido.quantidade = qtd_informada * fator
    @pedido.valor_total = (preco_base * qtd_informada * fator).round(2)
  end

  respond_to do |format|
    if @pedido.save
      # Não precisamos mais de update_columns aqui, pois já setamos os valores acima!
      @pedido.baixar_estoque 
      format.html { redirect_to @pedido, notice: "Pedido realizado com sucesso!" }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end

  def update
    respond_to do |format|
      if @pedido.update(pedido_params)
        format.html { redirect_to @pedido, notice: "Pedido atualizado com sucesso!", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pedido.destroy!
    respond_to do |format|
      format.html { redirect_to pedidos_path, notice: "Pedido excluído com sucesso!", status: :see_other }
    end
  end

  private

  def set_pedido
    # Removi o .expect que é de versões muito novas, usando o .find padrão
    @pedido = Pedido.find(params[:id])
  end

  def pedido_params
    # ADICIONADO :turno AQUI
    params.require(:pedido).permit(:produto_id, :cliente_nome, :quantidade, :unidade, :turno, :tamanho, :valor_total, :pago_dinheiro, :pago_pix, :pago_cartao_debito, :pago_cartao_credito, :observacao, ingredientes_removidos: [])
  end
end