class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show edit update destroy comprovante ]

  def index
    # Regra de Visualização do Histórico:
    if current_funcionario.admin?
      # Administrador tem visão macro: acompanha todas as unidades e turnos
      @pedidos = Pedido.all.order(created_at: :desc)
    else
      # Funcionário comum foca apenas na unidade em que está ativamente alocado
      @pedidos = Pedido.where(unidade: current_funcionario.unidade).order(created_at: :desc)
    end
  end

  def show
  end

  # Gera o cupom sem o layout do site
  def comprovante
    render layout: false
  end

  def new
    @pedido = Pedido.new
    @pedido.item_pedidos.build # Inicia o carrinho com um item vazio
  end

  def edit
  end

 def create
    @pedido = Pedido.new(pedido_params)
    @pedido.funcionario = current_funcionario
    @pedido.unidade     = current_funcionario.unidade
    @pedido.turno       = current_funcionario.turno
    
    total_acumulado = 0
    
    @pedido.item_pedidos.each do |item|
      produto = item.produto
      next unless produto
      
      # Define o preço base padrão do produto
      preco_final = produto.preco_venda.to_f
      
      # Se houver variação por tamanho, busca rigorosamente na tabela associada
      if item.tamanho.present?
        tamanho_busca = item.tamanho.to_s.strip.downcase
        variacao = produto.variacao_produtos.find { |v| v.tamanho.to_s.strip.downcase == tamanho_busca }
        preco_final = variacao.preco_venda.to_f if variacao
      end
      
      # Grava o preço definitivo diretamente na nova coluna do banco de dados
      item.preco_unitario = preco_final
      item.quantidade ||= 1
      total_acumulado += (preco_final * item.quantidade.to_f)
    end
    
    @pedido.valor_total = total_acumulado.round(2)

    respond_to do |format|
      if @pedido.save
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
        format.html { redirect_to @pedido, notice: "Pedido updated com sucesso!", status: :see_other }
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
    if current_funcionario.admin?
      @pedido = Pedido.find(params[:id])
    else
      @pedido = Pedido.where(unidade: current_funcionario.unidade).find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to pedidos_path, alert: "Pedido não encontrado ou acesso restrito a esta unidade."
  end

  def pedido_params
    params.require(:pedido).permit(
      :cliente_nome, :valor_total, 
      :pago_dinheiro, :pago_pix, :pago_cartao_debito, :pago_cartao_credito, :observacao,
      :ingredientes_removidos, :unidade, :turno,
      item_pedidos_attributes: [:id, :produto_id, :quantidade, :tamanho, :preco_unitario, :_destroy]
    )
  end
end