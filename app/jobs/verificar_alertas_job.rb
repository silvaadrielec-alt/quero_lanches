class VerificarAlertasJob < ApplicationJob
  queue_as :default

  def perform
    gestores = Funcionario.where(admin: true)
    return if gestores.blank?

    # =====================================================================
    # 1. VARREDURA DE FINANÇAS
    # =====================================================================
    despesas_criticas = Despesa.where(pago: false)
                               .where("data_vencimento <= ? OR data_vencimento BETWEEN ? AND ?", Date.today, Date.today, Date.today + 3.days)

    despesas_criticas.each do |despesa|
      if despesa.data_vencimento < Date.today
        status_texto = "JÁ VENCEU!"
        tag_alerta = "🔴"
      elsif despesa.data_vencimento == Date.today
        status_texto = "VENCE HOJE!"
        tag_alerta = "🟠"
      else
        dias_restantes = (despesa.data_vencimento - Date.today).to_i
        status_texto = "VENCE EM #{dias_restantes} DIAS"
        tag_alerta = "🟡"
      end

      titulo_alerta = "#{tag_alerta} Alerta Financeiro: #{despesa.descricao}"
      mensagem_detalhada = "A despesa '#{despesa.descricao}' no valor de R$ #{ActionController::Base.helpers.number_with_precision(despesa.valor, precision: 2, separator: ',', delimiter: '.')} está com o status: #{status_texto} (Vencimento: #{despesa.data_vencimento.strftime('%d/%m/%Y')})."

      ja_existe = Notificacao.exists?(titulo: titulo_alerta, lida: false)

      unless ja_existe
        Notificacao.create!(titulo: titulo_alerta, mensagem: mensagem_detalhada, tipo: "financeiro", lida: false)
        
        gestores.each do |gestor|
          if gestor.email.present?
            AlertaMailer.despesa_urgente(despesa, gestor).deliver_later
          end
        end
        Rails.logger.info " [Quero Lanches] Nova notificação de despesa criada: #{despesa.descricao}"
      end
    end

    # =====================================================================
    # 2. VARREDURA DE ESTOQUE CRÍTICO (Ajustado com os seus métodos reais!)
    # =====================================================================
    Produto.find_each do |produto|
      if produto.precisa_reposicao?
        
        # Identifica em quais locais específicos o estoque baixou para detalhar a mensagem
        locais = []
        locais << "Matriz" if produto.estoque_centro_baixo?
        locais << "Pav. Novo" if produto.estoque_pavilhao_novo_baixo?
        locais << "Pav. Antigo" if produto.estoque_pavilhao_antigo_baixo?
        
        titulo_estoque = " Estoque Crítico: #{produto.nome}"
        mensagem_estoque = "O item '#{produto.nome}' atingiu o limite crítico de segurança no(s) local(ais): #{locais.join(', ')}. Necessário realizar pedido de reposição de suprimentos."

        # Evita duplicar o aviso no sininho enquanto não for marcado como concluído
        existe_alerta = Notificacao.exists?(titulo: titulo_estoque, lida: false)

        unless existe_alerta
          Notificacao.create!(titulo: titulo_estoque, mensagem: mensagem_estoque, tipo: "estoque", lida: false)
          
          # Envia e-mail automático de alerta de insumos para a gestão
          gestores.each do |gestor|
            if gestor.email.present?
              AlertaMailer.estoque_critico(produto, gestor).deliver_later
            end
          end
          Rails.logger.info " [Quero Lanches] Alerta de estoque registrado para o insumo: #{produto.nome}"
        end
      end
    end

  end
end