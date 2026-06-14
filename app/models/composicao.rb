class Composicao < ApplicationRecord
  self.table_name = "composicaos" 

  belongs_to :produto
  belongs_to :insumo

  # 🌟 TRAVA CONTÁBIL: Impede a inserção duplicada do mesmo ingrediente na mesma receita.
  # Se o Davi quiser mudar a quantidade, ele deve remover a linha e lançar o valor correto.
  validates :insumo_id, uniqueness: { scope: :produto_id, message: "já está incluso na ficha técnica deste produto." }
  validates :quantidade, presence: { message: "não pode ficar em branco" }, numericality: { greater_than: 0, message: "deve ser maior que zero" }
  validates :unidade_medida_uso, presence: { message: "deve ser selecionada" }
end