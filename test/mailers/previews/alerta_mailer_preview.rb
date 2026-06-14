# Preview all emails at http://localhost:3000/rails/mailers/alerta_mailer
class AlertaMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/alerta_mailer/despesa_urgente
  def despesa_urgente
    AlertaMailer.despesa_urgente
  end

  # Preview this email at http://localhost:3000/rails/mailers/alerta_mailer/estoque_critico
  def estoque_critico
    AlertaMailer.estoque_critico
  end
end
