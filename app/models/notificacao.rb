class Notificacao < ApplicationRecord
  # Validações básicas para não salvar lixo
  validates :mensagem, presence: true

  # 🌟 A MÁGICA DO TURBO:
  # Sempre que uma notificação for criada, alterada (lida) ou apagada,
  # o Rails vai transmitir (broadcast) o novo pedaço do badge para todos os navegadores.
  after_create_commit  :atualizar_badge
  after_update_commit  :atualizar_badge
  after_destroy_commit :atualizar_badge

  private

  def atualizar_badge
    # "notificacoes_global" é o nome do canal de rádio que o layout vai escutar
    broadcast_replace_to "notificacoes_global",
                        target: "badge-wrapper",
                        partial: "notificacaos/badge"
  end
end
