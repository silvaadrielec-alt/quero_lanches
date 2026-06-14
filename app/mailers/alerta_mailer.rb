class AlertaMailer < ApplicationMailer
  # O e-mail de saída do sistema (o remetente) pode ser controlado por ENV para segurança
  default from: ENV['GMAIL_USER'] || 'sistema.querolanches@gmail.com'

  def despesa_urgente(despesa, funcionario_admin)
    @despesa = despesa
    @admin = funcionario_admin
    
    # Pega o e-mail real armazenado no cadastro do funcionário admin!
    mail(
      to: @admin.email, 
      subject: " [Quero Lanches] Alerta de Vencimento: #{despesa.descricao}"
    )
  end
end
