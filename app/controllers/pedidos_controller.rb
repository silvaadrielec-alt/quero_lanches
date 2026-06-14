class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show destroy comprovante ]

  def index
  if current_funcionario.admin?
    # Agora estamos filtrando pelo ID (unidade_id), que é o campo correto
    if params[:unidade_id].present?
      @pedidos = Pedido.where(unidade_id: params[:unidade_id]).order(created_at: :desc)
    else
      @pedidos = Pedido.all.order(created_at: :desc)
    end
  else
    # Funcionário comum restrito pela sua unidade
    @pedidos = Pedido.where(unidade_id: current_funcionario.unidade_id).order(created_at: :desc)
  end
end

  def show; end

  def comprovante
    render layout: false
  end

  def new
    @pedido = Pedido.new
    @pedido.item_pedidos.build 
  end

  def adicionar_item
    @index = Time.current.to_i
    @pedido = Pedido.new
    @item_pedido = @pedido.item_pedidos.build
    respond_to { |format| format.turbo_stream }
  end

  def adicionar_adicional
    @index_item = params[:index_item]
    @index_adicional = Time.current.to_i 
    @pedido = Pedido.new
    @item_pedido = @pedido.item_pedidos.build
    @adicional = @item_pedido.item_pedido_adicionais.build
    respond_to { |format| format.turbo_stream }
  end

  def edit
    redirect_to pedidos_path, alert: "A edição de pedidos foi desativada por motivos de segurança."
  end

  def update
    redirect_to pedidos_path, alert: "A edição de pedidos foi desativada por motivos de segurança."
  end

  def create
  @pedido = Pedido.new(pedido_params)
  @pedido.funcionario = current_funcionario
  # A relação já existe, basta atribuir o objeto
  @pedido.unidade = current_funcionario.unidade 
  @pedido.turno = current_funcionario.turno
    
    total_acumulado = 0
    
    @pedido.item_pedidos.each do |item|
      produto = item.produto
      next unless produto
      
      preco_final = produto.preco_venda.to_f
      if item.tamanho.present?
        tamanho_busca = item.tamanho.to_s.strip.downcase
        variacao = produto.variacao_produtos.find { |v| v.tamanho.to_s.strip.downcase == tamanho_busca }
        preco_final = variacao.preco_venda.to_f if variacao
      end
      
      item.preco_unitario = preco_final
      item.quantidade ||= 1
      
      total_adicionais = 0
      item.item_pedido_adicionais.each do |ipa|
        insumo_add = ipa.insumo
        next unless insumo_add
        preco_add = insumo_add.preco_venda.to_f
        ipa.preco_unitario = preco_add
        ipa.quantidade ||= 1
        total_adicionais += (preco_add * ipa.quantidade.to_f)
      end
      
      total_acumulado += ((preco_final + total_adicionais) * item.quantidade.to_f)
    end
    
    @pedido.valor_total = total_acumulado.round(2)
    # (Mantive suas validações de pagamento aqui, elas estão corretas)

    respond_to do |format|
      if @pedido.errors.none?
        begin
          ActiveRecord::Base.transaction do
            @pedido.save!
            @pedido.baixar_estoque 
            if defined?(MovimentacaoFinanceira)
              MovimentacaoFinanceira.create!(
                pedido_id: @pedido.id, funcionario_id: current_funcionario.id, unidade: @pedido.unidade_id,
                turno: @pedido.turno, tipo: 'RECEITA', valor: @pedido.valor_total,
                pago_dinheiro: @pedido.pago_dinheiro.to_f, pago_pix: @pedido.pago_pix.to_f,
                pago_cartao_debito: @pedido.pago_cartao_debito.to_f, pago_cartao_credito: @pedido.pago_cartao_credito.to_f,
                descricao: "Recebimento da Venda ##{@pedido.id} no Caixa"
              )
            end
          end
          format.html { redirect_to @pedido, notice: "Pedido realizado com sucesso!" }
        rescue => e
          @pedido.errors.add(:base, "Erro operacional: #{e.message}")
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      ActiveRecord::Base.transaction do
        @pedido.auditar_cancelamento(current_funcionario.id)
        MovimentacaoFinanceira.where(pedido_id: @pedido.id).destroy_all if defined?(MovimentacaoFinanceira)
        @pedido.destroy!
      end
      redirect_to pedidos_path, notice: "Pedido excluído e estoque estornado!"
    rescue => e
      redirect_to pedidos_path, alert: "Erro ao estornar: #{e.message}"
    end
  end

  private

  # No set_pedido (private):
def set_pedido
  # Se for admin, busca em qualquer lugar. Se não, apenas na unidade_id dele.
  @pedido = if current_funcionario.admin?
              Pedido.find(params[:id])
            else
              current_funcionario.unidade.pedidos.find(params[:id])
            end
rescue ActiveRecord::RecordNotFound
  redirect_to pedidos_path, alert: "Acesso restrito ou pedido não encontrado."
end

  def pedido_params
    params.require(:pedido).permit(
      :cliente_nome, :valor_total, :pago_dinheiro, :pago_pix, :pago_cartao_debito, :pago_cartao_credito, 
      :observacao, :ingredientes_removidos, :turno, :unidade_id,
      item_pedidos_attributes: [
        :id, :produto_id, :quantidade, :tamanho, :preco_unitario, :_destroy,
        item_pedido_adicionais_attributes: [:id, :insumo_id, :quantidade, :preco_unitario, :_destroy]
      ]
    )
  end
end