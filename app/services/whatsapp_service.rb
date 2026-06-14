require 'twilio-ruby'

class WhatsappService
  def self.enviar_alerta(mensagem, telefone_destino)
    # Chaves de autenticação da Twilio (puxadas do ambiente)
    account_sid   = ENV['TWILIO_ACCOUNT_SID'] || 'SUA_ACCOUNT_SID_AQUI'
    auth_token    = ENV['TWILIO_AUTH_TOKEN'] || 'SEU_AUTH_TOKEN_AQUI'
    from_whatsapp = ENV['TWILIO_WHATSAPP_NUMBER'] || 'whatsapp:+14155238886'

    client = Twilio::REST::Client.new(account_sid, auth_token)

    client.messages.create(
      from: from_whatsapp,
      to: "whatsapp:#{telefone_destino}",
      body: mensagem
    )
    
    Rails.logger.info " [WhatsApp] Mensagem de alerta enviada com sucesso para #{telefone_destino}!"
  rescue StandardError => e
    Rails.logger.error "❌ [WhatsApp] Erro crítico ao tentar enviar mensagem: #{e.message}"
    false
  end
end