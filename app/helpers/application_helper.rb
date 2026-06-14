module ApplicationHelper
  # Método que você já tem para as notificações
  def total_notificacoes_nao_lidas
    Rails.cache.fetch("notificacoes_#{current_funcionario.id}", expires_in: 1.minute) do
      Notificacao.where(lida: false).count
    end
  end

  # Novo método padronizado para todos os botões de excluir do sistema
  def botao_excluir(caminho, texto: 'EXCLUIR', mensagem: 'Deseja realmente apagar este registro?', estilo: nil)
    estilo_padrao = "background: #fef2f2; color: #dc2626; border: 1px solid #fee2e2; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.2s; text-decoration: none; display: inline-block; text-align: center;"
    
    link_to texto, caminho, 
      data: { 
        turbo_method: :delete, 
        confirm_swal: true, 
        confirm_text: mensagem 
      }, 
      style: estilo || estilo_padrao
  end
end