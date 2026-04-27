class Composicao < ApplicationRecord
  # Nome da tabela no banco de dados (para evitar erro de plural)
  self.table_name = "composicaos" 

  belongs_to :produto
  belongs_to :insumo, class_name: "Produto"
end
