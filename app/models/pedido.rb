class Pedido < ApplicationRecord
  # RELACIONAMENTOS ATUALIZADOS
  has_many :item_pedidos, dependent: :destroy
  belongs_to :cliente, optional: true
  belongs_to :funcionario

  # Aceita os atributos dos itens vindos do formulário (Carrinho de compras)
  accepts_nested_attributes_for :item_pedidos, allow_destroy: true, reject_if: :all_blank

  # Campos virtuais para capturar os dados do formulário
  attr_accessor :ingredientes_removidos

  # CALLBACKS
  before_destroy :devolver_estoque

  # VALIDAÇÕES
  validate :verificar_disponibilidade_estoque, on: :create
  validate :verificar_pagamento, on: :create
  validates :valor_total, numericality: { greater_than: 0, message: "não pode ser zero. Adicione pelo menos um item ao pedido." }

  def total_pago
    (pago_dinheiro.to_f + pago_pix.to_f + pago_cartao_debito.to_f + pago_cartao_credito.to_f).round(2)
  end

  def calcular_troco
    return 0 if total_pago == 0
    total_pago - self.valor_total.to_f
  end

  # Passa o item do carrinho para calcular a proporção exata do tamanho vendido
  def baixar_estoque
    unidade_venda = self.unidade.to_s.downcase.strip

    item_pedidos.each do |item_do_carrinho|
      p = item_do_carrinho.produto
      next unless p
      
      qtd_vendida = item_do_carrinho.quantidade.to_f
      p.reload
      
      # CALCULA O FATOR PARA LÍQUIDOS E PESADOS
      fator = descobrir_fator_proporcao(p, item_do_carrinho)
      
      # Se a unidade do cadastro for Litro ou KG, a quantidade gravada vira a fração proporcional
      unidade_prod = p.respond_to?(:unidade_medida) ? p.unidade_medida.to_s.downcase.strip : ""
      if unidad_prod == 'litro' || unidade_prod == 'kg' || unidade_prod == 'quilo'
        qtd_principal_ajustada = fator * qtd_vendida
      else
        qtd_principal_ajustada = qtd_vendida
      end
      
      # 1. Baixa e registra o produto principal daquela linha (lanche/suco/açaí)
      atualizar_estoque_unidade(p, qtd_principal_ajustada)
      registrar_movimentacao_auditoria(p, qtd_principal_ajustada, unidade_venda, "SAÍDA")

      # 2. Baixa e registra os insumos da ficha técnica com volumetria proporcional
      p.composicoes.each do |comp|
        next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
        
        insumo = comp.insumo
        next unless insumo
        insumo.reload
        
        # Quantidade física real abatida aplicando a regra de proporção do tamanho do copo/tigela
        qtd_gasta = calcular_quantidade_real(comp, item_do_carrinho) * qtd_vendida
        atualizar_estoque_unidade(insumo, qtd_gasta)
        
        # Quantidade comercial legível para os logs de auditoria humana
        qtd_auditoria = (comp.quantidade.to_f * fator) * qtd_vendida
        registrar_movimentacao_auditoria(insumo, qtd_auditoria, unidade_venda, "SAÍDA")
      end
    end
  end

  private

  def registrar_movimentacao_auditoria(item, quantidade, unidade_texto, acao_tipo)
    return unless defined?(Movimentacao)

    Movimentacao.create!(
      created_at: Time.current,
      funcionario_id: self.funcionario_id, 
      unidade: unidade_texto.upcase,
      produto_id: item.id,
      tipo_movimentacao: acao_tipo,
      quantidade: quantidade.round(3)
    )
  end

  def verificar_pagamento
    puts "DEBUG: Total Pedido: #{self.valor_total.to_f} | Total Pago: #{total_pago}"
    
    if self.valor_total.to_f > 0 && total_pago < self.valor_total.to_f
      errors.add(:base, "O valor pago (R$ #{total_pago}) é menor que o total do pedido (R$ #{self.valor_total.to_f})")
    end
  end

  # AJUSTADO: Adicionado 700ml, Porções em gramas e Abate por Peso Vivo (KG)
  def descobrir_fator_proporcao(produto, item_do_carrinho)
    nome_prod = produto.nome.to_s.downcase
    tamanho_form = item_do_carrinho.tamanho.to_s.downcase.strip

    bebidas_e_pesados = ['suco', 'vitamina', 'açaí', 'acai', 'café', 'cafe', 'chá', 'cha', 'bebida', 'chocolate', 'sorvete']

    if bebidas_e_pesados.any? { |termo| nome_prod.include?(termo) } || (produto.respond_to?(:unidade_medida) && ['litro', 'kg', 'quilo'].include?(produto.unidade_medida.to_s.downcase.strip))
      
      # --- 1. CHECAGEM PELO FORMULÁRIO (SELECT) ---
      if tamanho_form.include?('200')
        return 0.2
      elsif tamanho_form.include?('300')
        return 0.3
      elsif tamanho_form.include?('500')
        return 0.5
      elsif tamanho_form.include?('700')
        return 0.7
      elsif tamanho_form.include?('1 l') || tamanho_form.include?('1l') || tamanho_form.include?('jarra')
        return 1.0
      # Suporte para porções fixas em gramas (Ex: Tigela 300g vira 0.3 kg, Porção 500g vira 0.5 kg)
      elsif tamanho_form.include?('300g') || tamanho_form.include?('300 g')
        return 0.3
      elsif tamanho_form.include?('500g') || tamanho_form.include?('500 g')
        return 0.5
      # Se for açaí self-service vendido puramente pelo peso digitado no campo quantidade (1 unidade = 1 kg)
      elsif tamanho_form.include?('quilo') || tamanho_form.include?('kg') || tamanho_form.include?('peso')
        return 1.0
      elsif tamanho_form.include?('padrão') || tamanho_form.include?('padrao')
        return 1.0
      
      # --- 2. FALLBACK PELO NOME DO PRODUTO ---
      elsif nome_prod.include?('200ml') || nome_prod.include?('200 ml')
        return 0.2
      elsif nome_prod.include?('300ml') || nome_prod.include?('300 ml')
        return 0.3
      elsif nome_prod.include?('500ml') || nome_prod.include?('500 ml')
        return 0.5
      elsif nome_prod.include?('700ml') || nome_prod.include?('700 ml')
        return 0.7
      elsif nome_prod.include?('300g') || nome_prod.include?('300 g')
        return 0.3
      elsif nome_prod.include?('500g') || nome_prod.include?('500 g')
        return 0.5
      end
    end

    1.0
  end

  # Recebe o item do carrinho para aplicar a regra de três
  def calcular_quantidade_real(composicao, item_do_carrinho = nil)
    qtd = composicao.quantidade.to_f
    u = composicao.unidade_medida_uso.to_s.downcase.strip
    insumo = composicao.insumo
    return qtd unless insumo

    unidade_estoque = insumo.unidade_medida.to_s.downcase.strip
    nome_insumo = insumo.nome.to_s.downcase
    nome_produto = composicao.produto&.nome.to_s.downcase

    # Aplica o fator de proporção de tamanho se o item do carrinho for informado
    if item_do_carrinho
      fator_proporcao = descobrir_fator_proporcao(composicao.produto, item_do_carrinho)
      qtd = qtd * fator_proporcao
    end

    # --- REGRA ESPECIAL EXCLUSIVA PARA O AÇAÍ ---
    if nome_insumo.include?('açaí') || nome_insumo.include?('acai') || nome_produto.include?('açaí') || nome_produto.include?('acai')
      if (u.include?('ml') || u.include?('grama') || u.include?('g')) && (unidade_estoque.include?('l') || unidade_estoque.include?('kg'))
        return qtd / 1000.0
      elsif u.include?('unidade') || u.include?('copo')
        return qtd
      end
    end

    # --- REGRAS MATEMÁTICAS POR UNIDADE DE USO ---
    case u
    when 'gramas', 'ml', 'g'
      if unidade_estoque.include?('kg') || unidade_estoque.include?('l')
        qtd / 1000.0
      else
        qtd
      end

    when 'fatia', 'rodela', 'folha', 'unidade'
      if unidade_estoque.include?('kg')
        fator_banco = insumo.media_unidades_kg.to_f
        fator_calculo = if fator_banco > 1.0
                          fator_banco
                        else
                          case u
                          when 'fatia'   then 40.0  
                          when 'rodela'  then 50.0  
                          when 'folha'   then 100.0 
                          else 1.0
                          end
                        end
        (qtd / fator_calculo).round(4)
      else
        if u == 'folha' && unidade_estoque.include?('unidade')
          fator_banco = insumo.media_unidades_kg.to_f
          fator_pe = fator_banco > 1.0 ? fator_banco : 20.0
          (qtd / fator_pe).round(4)
        else
          qtd
        end
      end

    when 'kg', 'l', 'litro'
      qtd

    else
      qtd
    end
  end

  # Validação também passa a respeitar a proporção do tamanho para não dar falso bloqueio
  def verificar_disponibilidade_estoque
    unidade_venda = self.unidade.to_s.downcase.strip

    item_pedidos.each do |item_do_carrinho|
      p = item_do_carrinho.produto
      next unless p
      qtd_vendida = item_do_carrinho.quantidade.to_f

      p.composicoes.each do |comp|
        next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
        insumo = comp.insumo
        next unless insumo
        
        qtd_necessaria = calcular_quantidade_real(comp, item_do_carrinho) * qtd_vendida
        
        estoque_atual = case unidade_venda
                        when /centro/ then insumo.estoque_centro.to_f
                        when /novo/   then insumo.estoque_pavilhao_novo.to_f
                        when /antigo/ then insumo.estoque_pavilhao_antigo.to_f
                        else 0
                        end

        if estoque_atual < qtd_necessaria
          errors.add(:base, "Estoque insuficiente de #{insumo.nome} no #{self.unidade}. Disp: #{estoque_atual.round(3)}")
        end
      end
    end
  end

  def atualizar_estoque_unidade(item, valor)
    unidade_venda = self.unidade.to_s.downcase.strip
    
    if unidade_venda.include?('centro')
      novo_valor = (item.estoque_centro.to_f - valor.to_f).round(3)
      item.update_column(:estoque_centro, novo_valor)
    elsif unidade_venda.include?('novo')
      novo_valor = (item.estoque_pavilhao_novo.to_f - valor.to_f).round(3)
      item.update_column(:estoque_pavilhao_novo, novo_valor)
    elsif unidade_venda.include?('antigo')
      novo_valor = (item.estoque_pavilhao_antigo.to_f - valor.to_f).round(3)
      item.update_column(:estoque_pavilhao_antigo, novo_valor)
    end
  end

  # Estorno também passa o item do carrinho para devolver a fração exata calculada
  def devolver_estoque
    unidade_venda = self.unidade.to_s.downcase.strip
    coluna = case unidade_venda
             when /centro/ then :estoque_centro
             when /novo/   then :estoque_pavilhao_novo
             when /antigo/ then :estoque_pavilhao_antigo
             end

    return unless coluna

    item_pedidos.each do |item_do_carrinho|
      p = item_do_carrinho.produto
      next unless p
      qtd_vendida = item_do_carrinho.quantidade.to_f

      p.reload
      fator = descobrir_fator_proporcao(p, item_do_carrinho)
      
      unidade_prod = p.respond_to?(:unidade_medida) ? p.unidade_medida.to_s.downcase.strip : ""
      if unidade_prod == 'litro' || unidade_prod == 'kg' || unidade_prod == 'quilo'
        qtd_principal_ajustada = fator * qtd_vendida
      else
        qtd_principal_ajustada = qtd_vendida
      end

      novo_estoque_p = (p.send(coluna).to_f + qtd_principal_ajustada.to_f).round(3)
      p.update_column(coluna, novo_estoque_p)
      registrar_movimentacao_auditoria(p, qtd_principal_ajustada, unidade_venda, "ENTRADA (ESTORNO)")

      p.composicoes.each do |comp|
        next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
        insumo = comp.insumo
        next unless insumo
        
        insumo.reload
        qtd_para_devolver = calcular_quantidade_real(comp, item_do_carrinho) * qtd_vendida
        novo_estoque_i = (insumo.send(coluna).to_f + qtd_para_devolver).round(3)
        insumo.update_column(coluna, novo_estoque_i)
        
        qtd_auditoria_dev = (comp.quantidade.to_f * fator) * qtd_vendida
        registrar_movimentacao_auditoria(insumo, qtd_auditoria_dev, unidade_venda, "ENTRADA (ESTORNO)")
      end
    end
  end
end