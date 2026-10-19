module EstoqueCalculavel
  extend ActiveSupport::Concern

  # --- MÉTODOS PÚBLICOS ---

  def verificar_disponibilidade_estoque
    nome_unidade = self.unidade&.nome || "Indefinida"
    coluna = self.unidade&.tipo_estoque
    
    item_pedidos.each do |item_do_carrinho|
      p = item_do_carrinho.produto
      next unless p
      
      qtd_vendida = item_do_carrinho.quantidade.to_f

      # 1. Validação de Produto Simples
      if p.respond_to?(coluna) && p.composicoes.empty?
        next unless p.respond_to?(:estoque_controlado?) && p.estoque_controlado?
        qtd_necessaria = descobrir_fator_proporcao(p, item_do_carrinho) * qtd_vendida
        estoque_atual = p.send(coluna).to_f
        if estoque_atual < qtd_necessaria
          errors.add(:base, "Estoque insuficiente de #{p.nome} no #{nome_unidade}. Disponível: #{estoque_atual.round(0)} un")
        end
      end

      # 2. Validação de Insumos (Composições)
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

      # 3. Validação de Adicionais
      item_do_carrinho.item_pedido_adicionais.each do |ipa|
        add_insumo = ipa.insumo
        next unless add_insumo
        
        qtd_add_necessaria = CalculadorEstoqueService.calcular_baixa(add_insumo, ipa.quantidade.to_f) * qtd_vendida
        estoque_add = add_insumo.respond_to?(coluna) ? add_insumo.send(coluna).to_f : 0

        if estoque_add < qtd_add_necessaria
          errors.add(:base, "Estoque insuficiente do adicional #{add_insumo.nome} no #{nome_unidade}. Disponível: #{estoque_add.round(3)}")
        end
      end
    end
  end

  def baixar_estoque
    processar_movimentacao_estoque(:subtrair)
  end

  def devolver_estoque
    processar_movimentacao_estoque(:somar)
  end

  private

  # --- MÉTODOS DE PROCESSAMENTO (Otimizados) ---

  def processar_movimentacao_estoque(operacao)
    tipo_mov = operacao == :subtrair ? "SAÍDA" : "ENTRADA (ESTORNO)"

    item_pedidos.includes(produto: :composicoes).each do |item_carrinho|
    p = item_carrinho.produto
    next unless p
      
      # Distribuição inteligente de responsabilidade
      if p.composicoes.any?
        baixar_como_composto(p, item_carrinho, operacao, tipo_mov)
      else
        baixar_como_simples(p, item_carrinho, operacao, tipo_mov)
      end

      # Baixa de Adicionais (processada sempre)
      baixar_adicionais(item_carrinho, operacao, tipo_mov)
    end
  end

  def baixar_como_simples(produto, item, operacao, tipo_mov)
    return unless produto.respond_to?(:estoque_centro)
    qtd_ajustada = descobrir_fator_proporcao(produto, item) * item.quantidade.to_f
    atualizar_saldo_fisico(produto, qtd_ajustada, operacao)
    registrar_log_movimentacao(produto, qtd_ajustada, tipo_mov, item_pedido_id: item.id)
  end

  def baixar_como_composto(produto, item, operacao, tipo_mov)
    produto.composicoes.each do |comp|
      next if item.observacao.to_s.downcase.include?(comp.insumo.nome.to_s.downcase.strip)
      insumo = comp.insumo
      next unless insumo
      
      qtd_gasta = calcular_quantidade_real(comp, item) * item.quantidade.to_f
      atualizar_saldo_fisico(insumo, qtd_gasta, operacao)
      registrar_log_movimentacao(insumo, qtd_gasta, tipo_mov, item_pedido_id: item.id)
    end
  end

  def baixar_adicionais(item, operacao, tipo_mov)
    item.item_pedido_adicionais.each do |ipa|
      add_insumo = ipa.insumo
      next unless add_insumo
      
      qtd_add = CalculadorEstoqueService.calcular_baixa(add_insumo, ipa.quantidade.to_f) * item.quantidade.to_f
      atualizar_saldo_fisico(add_insumo, qtd_add, operacao)
      registrar_log_movimentacao(add_insumo, qtd_add, "#{tipo_mov} (ADICIONAL)", valor_receita: ipa.preco_unitario, item_pedido_id: item.id)
    end
  end

  # --- MÉTODOS AUXILIARES ---

  def calcular_quantidade_real(composicao, item_carrinho)
    qtd = composicao.quantidade.to_f
    fator = descobrir_fator_proporcao(composicao.produto, item_carrinho)
    unidade_uso = composicao.unidade_medida_uso.to_s.downcase
    insumo = composicao.insumo
    
    rendimento = insumo.respond_to?(:media_unidades_kg) ? insumo.media_unidades_kg.to_f : 1.0
    rendimento = 1.0 if rendimento <= 0

    qtd_ajustada = qtd * fator

    case unidade_uso
    when 'gramas', 'ml', 'g'
      qtd_ajustada / 1000.0
    when 'fatia', 'unidade', 'folha', 'rodela'
      qtd_ajustada / rendimento
    else
      qtd_ajustada
    end
  end

  def descobrir_fator_proporcao(produto, item_carrinho)
    tamanho = item_carrinho.tamanho.to_s.downcase
    return 0.2 if tamanho.include?('200')
    return 0.3 if tamanho.include?('300')
    return 0.5 if tamanho.include?('500')
    return 0.7 if tamanho.include?('700')
    return 1.0 if tamanho.match?(/1\s?l|jarra|kg/)
    1.0
  end

  def atualizar_saldo_fisico(item, quantidade, operacao)
    coluna = self.unidade&.tipo_estoque
    return unless coluna && item.respond_to?(coluna)
    saldo_atual = item.send(coluna).to_f
    novo_saldo = operacao == :subtrair ? (saldo_atual - quantidade) : (saldo_atual + quantidade)
    item.update_column(coluna, novo_saldo.round(3))
  end

  def registrar_log_movimentacao(item, quantidade, tipo, valor_receita: nil, item_pedido_id: nil)
    return unless defined?(Movimentacao)
    
    if valor_receita.nil? && item_pedido_id.present?
      item_pedido = ItemPedido.find_by(id: item_pedido_id)
      valor_receita = item_pedido.preco_unitario if item_pedido&.preco_unitario.present?
    end
    
    params = item.is_a?(Produto) ? { produto_id: item.id } : { insumo_id: item.id }
    unidade_medida = item.respond_to?(:unidade_medida) ? item.unidade_medida.to_s : "un"
    
    dados = {
      funcionario_id: self.funcionario_id, 
      unidade_id: self.unidade_id,
      tipo_movimentacao: tipo,
      quantidade: quantidade.round(3),
      unidade_medida: unidade_medida,
      item_pedido_id: item_pedido_id,
      valor_receita: valor_receita
    }.merge(params)

    dados[:valor_receita] = valor_receita if valor_receita.present?
    Movimentacao.create!(dados)
  end
end