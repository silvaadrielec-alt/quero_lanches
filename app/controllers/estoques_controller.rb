class EstoquesController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :set_item_repor, only: [:edit, :update]

  # Exibe o painel geral de saldos físicos
  def index
    @produtos_venda = Produto.where(categoria: ["Venda", nil], estoque_controlado: true)
    @insumos = Insumo.all
  end

  # Prepara a tela de compra/entrada futura em lote
  def lote
    @opcoes_estoque = []
    
    Produto.where(categoria: ["Venda", nil]).order(:nome).each do |p|
      @opcoes_estoque << { id: "PRODUTO-#{p.id}", nome: p.codigo.present? ? "[#{p.codigo}] #{p.nome.upcase} (CARDÁPIO)" : "#{p.nome.upcase} (CARDÁPIO)" }
    end

    Insumo.order(:nome).each do |i|
      @opcoes_estoque << { id: "INSUMO-#{i.id}", nome: "[INSUMO] #{i.nome.upcase}" }
    end
  end

 # Processa a entrada de quantidades em lote sem recadastrar o item

  def processar_lote

    unidade = params[:unidade]

    itens = params[:itens]



    if unidade.blank?

      flash[:alert] = "Por favor, selecione a unidade de destino."

      redirect_to lote_estoques_path and return

    end



    if itens.blank? || itens.values.all? { |i| i[:global_id].blank? || i[:quantidade].to_f <= 0 }

      flash[:alert] = "Adicione pelo menos um item com quantidade válida."

      redirect_to lote_estoques_path and return

    end



    contador_sucesso = 0



    ActiveRecord::Base.transaction do

      # 1. Blindagem: Tenta buscar pelo ID (se for numérico) ou pelo Nome (se for texto)

       # 1. Blindagem: Como a view agora envia sempre o ID (1, 2 ou 3), buscamos diretamente por ele.
      unidade_obj = Unidade.find_by(id: unidade)

      # 2. Proteção: Se o ID não existir, interrompemos a operação imediatamente.
      if unidade_obj.nil?
        raise "Unidade com ID '#{unidade}' não encontrada no sistema. Verifique o cadastro."
      end

      
      itens.each_value do |item|

        global_id = item[:global_id]

        quantidade = item[:quantidade].to_f



        next if global_id.blank? || quantidade <= 0



        tipo, id_real = global_id.split('-')

        objeto_alvo = tipo == "PRODUTO" ? Produto.find(id_real) : Insumo.find(id_real)



        # O case agora reconhece os IDs numéricos (como '2') e os nomes ('centro')

        coluna = case unidade.to_s

                 when '1', 'centro'          then :estoque_centro

                 when '2', 'pavilhao_novo'   then :estoque_pavilhao_novo

                 when '3', 'pavilhao_antigo' then :estoque_pavilhao_antigo

                 end



        if coluna && objeto_alvo.respond_to?(coluna)

          novo_valor = (objeto_alvo.send(coluna).to_f + quantidade).round(3)

          objeto_alvo.update_column(coluna, novo_valor)

        end



        polymorphic_params = objeto_alvo.is_a?(Produto) ? { produto_id: objeto_alvo.id } : { insumo_id: objeto_alvo.id }



        # Registra a trilha forense usando o objeto validado unidade_obj

        Movimentacao.create!(

          {

            funcionario: current_funcionario,

            quantidade: quantidade,

            tipo_movimentacao: 'ENTRADA',

            unidade: unidade_obj

          }.merge(polymorphic_params)

        )



        contador_sucesso += 1

      end

    end



    flash[:notice] = "Sucesso! Foram repostos #{contador_sucesso} itens na unidade #{unidade.upcase.gsub('_', ' ')}."

    redirect_to estoques_path

  rescue => e

    flash[:alert] = "Ocorreu um erro ao processar o lote: #{e.message}"

    redirect_to lote_estoques_path

  end 

  # Reposição rápida direto botão da tabela de estoque
  def repor
    quantidade_adicional = params[:quantidade].to_f
    unidade_nome = params[:unidade] || params[:unidade_destino]
    
    if params[:produto_id].present?
      @item = Produto.find(params[:produto_id])
      polymorphic_params = { produto_id: @item.id }
    elsif params[:insumo_id].present?
      @item = Insumo.find(params[:insumo_id])
      polymorphic_params = { insumo_id: @item.id }
    end

    if @item && quantidade_adicional > 0
      coluna = case unidade_nome
               when 'centro' then :estoque_centro
               when 'pavilhao_novo' then :estoque_pavilhao_novo
               when 'pavilhao_antigo' then :estoque_pavilhao_antigo
               end

      novo_valor = (@item.send(coluna).to_f + quantidade_adicional).round(3)
      @item.update_column(coluna, novo_valor)

      # CORREÇÃO AQUI: Buscamos o objeto unidade antes de criar a movimentação
      unidade_obj = Unidade.find_by(nome: unidade_nome.gsub('_', ' ').titleize)

      Movimentacao.create!(
        {
          funcionario: current_funcionario,
          quantidade: quantidade_adicional,
          tipo_movimentacao: 'ENTRADA',
          unidade: unidade_obj # Agora passamos o objeto (relação), não a string
        }.merge(polymorphic_params)
      )

      flash[:notice] = "Estoque de #{@item.nome.upcase} abastecido com +#{quantidade_adicional}!"
    else
      flash[:alert] = "Insira uma quantidade válida."
    end

    redirect_to estoques_path
  end

  def transferir
    origem = params[:unidade_origem]
    destino = params[:unidade_destino]
    quantidade = params[:quantidade].to_f

    if origem.blank? || destino.blank?
      flash[:alert] = "Selecione origem e destino."
      redirect_to estoques_path and return
    end

    # Identificar o item
    if params[:produto_id].present?
      @item = Produto.find(params[:produto_id])
      polymorphic_params = { produto_id: @item.id }
    elsif params[:insumo_id].present?
      @item = Insumo.find(params[:insumo_id])
      polymorphic_params = { insumo_id: @item.id }
    end

    if origem == destino
      flash[:alert] = "Origem e destino iguais."
    elsif @item && quantidade > 0
      ActiveRecord::Base.transaction do
        colunas = { 'centro' => :estoque_centro, 'pavilhao_novo' => :estoque_pavilhao_novo, 'pavilhao_antigo' => :estoque_pavilhao_antigo }

        @item.update_column(colunas[origem], (@item.send(colunas[origem]).to_f - quantidade).round(3))
        @item.update_column(colunas[destino], (@item.send(colunas[destino]).to_f + quantidade).round(3))

        # CORREÇÃO AQUI: Buscamos os objetos para passar para a Movimentação
        unidade_origem_obj = Unidade.find_by(nome: origem.gsub('_', ' ').titleize)
        unidade_destino_obj = Unidade.find_by(nome: destino.gsub('_', ' ').titleize)

        Movimentacao.create!(polymorphic_params.merge(funcionario: current_funcionario, quantidade: quantidade, tipo_movimentacao: 'SAIDA_TRANSFERENCIA', unidade: unidade_origem_obj))
        Movimentacao.create!(polymorphic_params.merge(funcionario: current_funcionario, quantidade: quantidade, tipo_movimentacao: 'ENTRADA_TRANSFERENCIA', unidade: unidade_destino_obj))
      end
      flash[:notice] = "Transferência concluída!"
    else
      flash[:alert] = "Dados inválidos."
    end
    redirect_to estoques_path
  end
  
  def edit
    # Abre o formulário compacto para alteração/ajuste manual de saldos
  end

  def update
    colunas = params.require(:item).permit(:estoque_centro, :estoque_pavilhao_novo, :estoque_pavilhao_antigo, :estoque_controlado)
    if @item.update(colunas)
      redirect_to estoques_path, notice: "Inventário atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def auditoria
    @movimentacoes = Movimentacao.includes(:produto, :insumo, :funcionario).all.order(created_at: :desc).limit(500)
  end

  private

  def set_item_repor
    if params[:tipo] == "Insumo"
      @item = Insumo.find(params[:id])
    else
      @item = Produto.find(params[:id])
    end
  end
end