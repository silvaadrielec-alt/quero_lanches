class Pedido < ApplicationRecord
  # RELACIONAMENTOS
  has_many :item_pedidos, dependent: :destroy
  belongs_to :cliente, optional: true
  belongs_to :funcionario
  belongs_to :unidade

  # Aceita os atributos dos itens vindos do formulário (Carrinho de compras)
  accepts_nested_attributes_for :item_pedidos, allow_destroy: true, reject_if: :all_blank

  # VALIDAÇÕES
  validate :verificar_disponibilidade_estoque, on: :create
  validate :verificar_pagamento, on: :create
  validates :valor_total, numericality: { greater_than: 0, message: "não pode ser zero. Adicione itens ao pedido." }

  # --- MÉTODOS DE APOIO FINANCEIRO ---

  def total_pago
    (pago_dinheiro.to_f + pago_pix.to_f + pago_cartao_debito.to_f + pago_cartao_credito.to_f).round(2)
  end

  def calcular_troco
    pago_dinheiro_valor = self.pago_dinheiro.to_f
    pago_eletronico = self.pago_pix.to_f + self.pago_cartao_debito.to_f + self.pago_cartao_credito.to_f
    
    return 0.0 if pago_dinheiro_valor == 0
    
    saldo_restante = self.valor_total.to_f - pago_eletronico
    return 0.0 if saldo_restante <= 0

    troco = pago_dinheiro_valor - saldo_restante
    troco > 0 ? troco.round(2) : 0.0
  end

  def recalcular_valor_total
    total = 0.0
    
    item_pedidos.each do |item|
      preco_item = item.produto&.preco_venda.to_f
      item.preco_unitario = preco_item
      
      total_adicionais = 0
      item.item_pedido_adicionais.each do |ipa|
        preco_ipa = ipa.preco_unitario.to_f > 0 ? ipa.preco_unitario.to_f : ipa.insumo&.preco_venda.to_f
        ipa.preco_unitario = preco_ipa
        total_adicionais += (ipa.quantidade.to_f * preco_ipa)
      end
      
      total += (preco_item * item.quantidade.to_f) + total_adicionais
    end
    
    self.valor_total = total.round(2)
  end

  # --- MOTOR DE ESTOQUE E AUDITORIA FORENSE ---

  def baixar_estoque
    processar_movimentacao_estoque(:subtrair)
  end

  def devolver_estoque
    processar_movimentacao_estoque(:somar)
  end

  def auditar_cancelamento(funcionario_id)
    return unless defined?(Auditorium)
    # CORREÇÃO: Passamos o ID da unidade para manter a integridade com o belongs_to :unidade
    Auditorium.create!(
      funcionario_id: funcionario_id,
      tabela_afetada: 'Pedidos',
      registro_id: self.id,
      unidade_id: self.unidade_id,
      acao: 'CANCELAMENTO',
      valor_anterior: self.valor_total,
      valor_novo: 0.0,
      descricao: "ALERTA: Venda ##{self.id} de R$ #{self.valor_total} CANCELADA. Estoque estornado."
    )
  end

  private

  def processar_movimentacao_estoque(operacao)
    tipo_mov = operacao == :subtrair ? "SAÍDA" : "ENTRADA (ESTORNO)"

    item_pedidos.each do |item_carrinho|
      p = item_carrinho.produto
      next unless p
      p.reload
      
      qtd_vendida = item_carrinho.quantidade.to_f
      fator = descobrir_fator_proporcao(p, item_carrinho)

      if p.respond_to?(:estoque_centro) && p.composicoes.empty?
        qtd_ajustada = (fator * qtd_vendida)
        atualizar_saldo_fisico(p, qtd_ajustada, operacao)
        registrar_log_movimentacao(p, qtd_ajustada, tipo_mov)
      end

      p.composicoes.each do |comp|
        next if item_carrinho.observacao.to_s.downcase.include?(comp.insumo.nome.to_s.downcase.strip)
        insumo = comp.insumo
        next unless insumo
        insumo.reload

        qtd_gasta = calcular_quantidade_real(comp, item_carrinho) * qtd_vendida
        atualizar_saldo_fisico(insumo, qtd_gasta, operacao)
        registrar_log_movimentacao(insumo, qtd_gasta, tipo_mov)
      end

      item_carrinho.item_pedido_adicionais.each do |ipa|
        add_insumo = ipa.insumo
        next unless add_insumo
        add_insumo.reload

        qtd_add = ipa.quantidade.to_f * qtd_vendida
        atualizar_saldo_fisico(add_insumo, qtd_add, operacao)
        registrar_log_movimentacao(add_insumo, qtd_add, "#{tipo_mov} (ADICIONAL)")
      end
    end
  end

  def atualizar_saldo_fisico(item, quantidade, operacao)
    coluna = self.unidade&.tipo_estoque
    return unless coluna && item.respond_to?(coluna)

    saldo_atual = item.send(coluna).to_f
    novo_saldo = operacao == :subtrair ? (saldo_atual - quantidade) : (saldo_atual + quantidade)
    item.update_column(coluna, novo_saldo.round(3))
  end

  def registrar_log_movimentacao(item, quantidade, tipo)
    return unless defined?(Movimentacao)
    params = item.is_a?(Produto) ? { produto_id: item.id } : { insumo_id: item.id }
    
    unidade_medida = item.respond_to?(:unidade_medida) ? item.unidade_medida.to_s : "un"
    
    # CORREÇÃO: Usamos unidade_id para garantir compatibilidade com o belongs_to :unidade
    Movimentacao.create!({
      funcionario_id: self.funcionario_id, 
      unidade_id: self.unidade_id,
      tipo_movimentacao: tipo,
      quantidade: quantidade.round(3),
      unidade_medida: unidade_medida
    }.merge(params))
  end

  def descobrir_fator_proporcao(produto, item_carrinho)
    tamanho = item_carrinho.tamanho.to_s.downcase
    return 0.2 if tamanho.include?('200')
    return 0.3 if tamanho.include?('300')
    return 0.5 if tamanho.include?('500')
    return 0.7 if tamanho.include?('700')
    return 1.0 if tamanho.include?('1 l') || tamanho.include?('1l') || tamanho.include?('jarra') || tamanho.include?('kg')
    1.0
  end

  def calcular_quantidade_real(composicao, item_carrinho)
    qtd = composicao.quantidade.to_f
    fator = descobrir_fator_proporcao(composicao.produto, item_carrinho)
    unidade_uso = composicao.unidade_medida_uso.to_s.downcase
    insumo = composicao.insumo

    qtd_ajustada = qtd * fator

    if ['gramas', 'ml', 'g'].include?(unidade_uso)
      qtd_ajustada / 1000.0
    elsif ['fatia', 'unidade', 'folha'].include?(unidade_uso)
      rendimento = insumo.media_unidades_kg.to_f
      rendimento > 0 ? (qtd_ajustada / rendimento) : qtd_ajustada
    else
      qtd_ajustada
    end
  end

  def verificar_pagamento
    if self.valor_total.to_f > 0 && total_pago < self.valor_total.to_f
      errors.add(:base, "O valor pago (R$ #{total_pago}) é menor que o total (R$ #{self.valor_total.to_f})")
    end
  end

  def verificar_disponibilidade_estoque
    nome_unidade = self.unidade&.nome || "Indefinida"

    item_pedidos.each do |item_do_carrinho|
      p = item_do_carrinho.produto
      next unless p
      
      qtd_vendida = item_do_carrinho.quantidade.to_f
      coluna = self.unidade&.tipo_estoque

      if p.respond_to?(coluna) && p.composicoes.empty?
        fator = descobrir_fator_proporcao(p, item_do_carrinho)
        qtd_necessaria = fator * qtd_vendida
        estoque_atual = p.send(coluna).to_f

        if estoque_atual < qtd_necessaria
          errors.add(:base, "Estoque insuficiente de #{p.nome} no #{nome_unidade}. Disponível: #{estoque_atual.round(0)} un")
        end
      end

      p.composicoes.each do |comp|
        next if item_do_carrinho.observacao.to_s.downcase.include?(comp.insumo.nome.to_s.downcase.strip)
        insumo = comp.insumo
        next unless insumo
        
        qtd_necessaria = calcular_quantidade_real(comp, item_do_carrinho) * qtd_vendida
        estoque_atual = insumo.respond_to?(coluna) ? insumo.send(coluna).to_f : 0

        if estoque_atual < qtd_necessaria
          unidade_medida = insumo.respond_to?(:unidade_medida) ? insumo.unidade_medida : "un"
          errors.add(:base, "Estoque insuficiente de #{insumo.nome} no #{nome_unidade}. Necessário: #{qtd_necessaria.round(3)}, Disponível: #{estoque_atual.round(3)} #{unidade_medida}")
        end
      end

      item_do_carrinho.item_pedido_adicionais.each do |ipa|
        add_insumo = ipa.insumo
        next unless add_insumo
        
        qtd_add_necessaria = ipa.quantidade.to_f * qtd_vendida
        estoque_add = add_insumo.respond_to?(coluna) ? add_insumo.send(coluna).to_f : 0

        if estoque_add < qtd_add_necessaria
          errors.add(:base, "Estoque insuficiente do adicional #{add_insumo.nome} no #{nome_unidade}. Disponível: #{estoque_add.round(3)}")
        end
      end
    end
  end
end