class CalculadorEstoqueService
  def self.calcular_baixa(insumo, quantidade_solicitada, fator_proporcao = 1.0)
    return 0 unless insumo

    rendimento = insumo.respond_to?(:media_unidades_kg) ? insumo.media_unidades_kg.to_f : 1.0
    rendimento = 1.0 if rendimento <= 0

    # Aplica o fator (tamanho do lanche) à quantidade base
    quantidade_ajustada = quantidade_solicitada * fator_proporcao

   # Tradutor de Medidas
    case insumo.unidade_medida.to_s.downcase
    # 1. Primeiro verifica se existe rendimento (fatias/unidades)
    when 'fatia', 'unidade', 'un', 'folha', 'rodela'
      quantidade_ajustada / rendimento
      
    # 2. Se for 'kg' mas tiver rendimento (o caso do queijo), faz a conta certa
    when 'kg'
      (rendimento > 0) ? (quantidade_ajustada / rendimento) : quantidade_ajustada
      
    # 3. Se for peso real em gramas/ml
    when 'gramas', 'g'
      quantidade_ajustada / 1000.0
    when 'ml'
      quantidade_ajustada / 1000.0
      
    else
      quantidade_ajustada
    end
  end
end