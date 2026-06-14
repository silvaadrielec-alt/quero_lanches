class Unidade < ApplicationRecord
  has_many :pedidos
  
  def tipo_estoque
    nome_down = nome.to_s.downcase
    return :estoque_centro if nome_down.include?('centro')
    return :estoque_pavilhao_novo if nome_down.include?('novo')
    return :estoque_pavilhao_antigo if nome_down.include?('antigo')
    
    # Adicionamos um fallback: se não achar, retorna a coluna de estoque padrão
    # ou loga um erro para você saber qual unidade está falhando
    Rails.logger.error "Unidade #{nome} não mapeada para estoque!"
    :estoque_centro # ou a coluna padrão que faz mais sentido aí
  end
end
