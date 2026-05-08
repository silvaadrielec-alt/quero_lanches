class Pedido < ApplicationRecord
  belongs_to :produto
  belongs_to :cliente, optional: true
  belongs_to :funcionario

  # Campos virtuais para capturar os dados do formulário
  attr_accessor :ingredientes_removidos

  # CALLBACKS
  # O devolver_estoque garante que ao excluir um pedido, o estoque volte e registre na auditoria
  before_destroy :devolver_estoque

  # VALIDAÇÕES
  validate :verificar_disponibilidade_estoque, on: :create
  validate :verificar_pagamento, on: :create
  validates :valor_total, numericality: { greater_than: 0, message: "não pode ser zero. Verifique o preço do produto." }

  def total_pago
    (pago_dinheiro.to_f + pago_pix.to_f + pago_cartao_debito.to_f + pago_cartao_credito.to_f).round(2)
  end

  def calcular_troco
    return 0 if total_pago == 0
    total_pago - self.valor_total.to_f
  end

  def baixar_estoque
    p = Produto.find(self.produto_id)
    qtd_vendida = self.quantidade.to_f
    unidade_venda = self.unidade.to_s.downcase.strip
    
    # 1. Baixa e registra o produto principal
    atualizar_estoque_unidade(p, qtd_vendida)
    registrar_movimentacao_auditoria(p, qtd_vendida, unidade_venda, "SAÍDA")

    # 2. Baixa e registra os insumos da ficha técnica
    p.composicoes.each do |comp|
      next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
      insumo = comp.insumo
      qtd_gasta = calcular_quantidade_real(comp) * qtd_vendida
      
      atualizar_estoque_unidade(insumo, qtd_gasta)
      registrar_movimentacao_auditoria(insumo, qtd_gasta, unidade_venda, "SAÍDA")
    end
  end

  private

  def registrar_movimentacao_auditoria(item, quantidade, unidade_texto, acao_tipo)
    # Verifica se o modelo Auditoria existe antes de tentar criar
    return unless defined?(Movimentacao)

    Movimentacao.create!(
      created_at: Time.current,
    funcionario_id: self.funcionario_id, 
    unidade: unidade_texto.upcase,
    produto_id: item.id,
    tipo_movimentacao: acao_tipo, # Nome real da coluna no seu banco
    quantidade: quantidade.round(3) # Nome real da coluna no seu banco
    )
  end

  def verificar_pagamento
    puts "DEBUG: Total Pedido: #{self.valor_total.to_f} | Total Pago: #{total_pago}"
    
    if self.valor_total.to_f > 0 && total_pago < self.valor_total.to_f
      errors.add(:base, "O valor pago (R$ #{total_pago}) é menor que o total do pedido (R$ #{self.valor_total.to_f})")
    end
  end

  def calcular_quantidade_real(composicao)
    qtd = composicao.quantidade.to_f
    u = composicao.unidade_medida_uso.to_s.downcase.strip
    insumo = composicao.insumo
    nome_insumo = insumo.nome.to_s.downcase

    if u.include?('ml') || u.include?('grama') || (nome_insumo.include?('açaí') && qtd > 10)
      qtd / 1000.0
    elsif u.include?('kg')
      fator_peso = insumo.media_unidades_kg.to_f > 0 ? insumo.media_unidades_kg.to_f : 0.9
      qtd / fator_peso
    elsif u.include?('un') || u.include?('fat') || u.include?('rod')
      media = insumo.media_unidades_kg.to_f > 0 ? insumo.media_unidades_kg.to_f : 1.0
      qtd / media
    else
      qtd
    end
  end

  def verificar_disponibilidade_estoque
    p = Produto.find(self.produto_id)
    qtd_vendida = self.quantidade.to_f
    unidade_venda = self.unidade.to_s.downcase.strip

    p.composicoes.each do |comp|
      next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
      insumo = comp.insumo
      qtd_necessaria = calcular_quantidade_real(comp) * qtd_vendida
      
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

  def atualizar_estoque_unidade(item, valor)
    unidade_venda = self.unidade.to_s.downcase.strip
    if unidade_venda.include?('centro')
      item.decrement!(:estoque_centro, valor)
    elsif unidade_venda.include?('novo')
      item.decrement!(:estoque_pavilhao_novo, valor)
    elsif unidade_venda.include?('antigo')
      item.decrement!(:estoque_pavilhao_antigo, valor)
    end
  end

  def devolver_estoque
    p = self.produto
    qtd_vendida = self.quantidade.to_f
    unidade_venda = self.unidade.to_s.downcase.strip
    coluna = case unidade_venda
             when /centro/ then :estoque_centro
             when /novo/   then :estoque_pavilhao_novo
             when /antigo/ then :estoque_pavilhao_antigo
             end

    return unless coluna

    # Devolve o produto e registra estorno na auditoria
    p.increment!(coluna, qtd_vendida)
    registrar_movimentacao_auditoria(p, qtd_vendida, unidade_venda, "ENTRADA (ESTORNO)")

    # Devolve os insumos e registra estorno na auditoria
    p.composicoes.each do |comp|
      next if ingredientes_removidos&.include?(comp.insumo_id.to_s)
      qtd_para_devolver = calcular_quantidade_real(comp) * qtd_vendida
      comp.insumo.increment!(coluna, qtd_para_devolver)
      registrar_movimentacao_auditoria(comp.insumo, qtd_para_devolver, unidade_venda, "ENTRADA (ESTORNO)")
    end
  end
end