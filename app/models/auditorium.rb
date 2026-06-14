class Auditorium < ApplicationRecord
  self.table_name = 'auditoria'
  # Permitir que a auditoria registre ações automáticas do sistema se não houver funcionário logado
  belongs_to :funcionario, optional: true
  belongs_to :unidade
end
