class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show edit update destroy ]

  # GET /pedidos or /pedidos.json
  def index
    @pedidos = Pedido.all
  end

  # GET /pedidos/1 or /pedidos/1.json
  def show
  end

  # GET /pedidos/new
  def new
    @pedido = Pedido.new
  end

  # GET /pedidos/1/edit
  def edit
  end

  # POST /pedidos or /pedidos.json
 def create
  @pedido = Pedido.new(pedido_params)
  @pedido.funcionario = current_funcionario
  
  # Buscamos o produto que está sendo vendido
  @produto = Produto.find(@pedido.produto_id)

  respond_to do |format|
    if @pedido.save
      # --- LÓGICA DE BAIXA DE ESTOQUE ---
      # Verificamos qual unidade foi selecionada no formulário e subtraímos
      case @pedido.unidade
      when 'centro'
        nova_qtd = (@produto.estoque_centro || 0) - @pedido.quantidade
        @produto.update(estoque_centro: nova_qtd)
      when 'pavilhao_novo'
        nova_qtd = (@produto.estoque_pavilhao_novo || 0) - @pedido.quantidade
        @produto.update(estoque_pavilhao_novo: nova_qtd)
      when 'pavilhao_antigo'
        nova_qtd = (@produto.estoque_pavilhao_antigo || 0) - @pedido.quantidade
        @produto.update(estoque_pavilhao_antigo: nova_qtd)
      end
      # ----------------------------------

      format.html { redirect_to @pedido, notice: "Pedido realizado e estoque atualizado!" }
      format.json { render :show, status: :created, location: @pedido }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @pedido.errors, status: :unprocessable_entity }
    end
  end
end

  # PATCH/PUT /pedidos/1 or /pedidos/1.json
  def update
    respond_to do |format|
      if @pedido.update(pedido_params)
        format.html { redirect_to @pedido, notice: "Pedido atualizado com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: @pedido }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pedido.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pedidos/1 or /pedidos/1.json
  def destroy
    @pedido.destroy!

    respond_to do |format|
      format.html { redirect_to pedidos_path, notice: "Pedido excluído com sucesso!", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pedido
      @pedido = Pedido.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pedido_params
      params.require(:pedido).permit(:produto_id, :cliente_nome, :quantidade, :unidade, :valor_total, ingredientes_removidos: [])
    end
end
