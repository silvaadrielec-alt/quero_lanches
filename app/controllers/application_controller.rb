class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Esta linha obriga o check-in em todas as páginas, exceto no login/logout e no próprio check-in
  before_action :verificar_checkin_turno, unless: :devise_controller?

  def after_sign_in_path_for(resource)
    veio_da_porta_admin = request.env['HTTP_REFERER']&.include?('role=admin') || params[:role] == 'admin'

    if veio_da_porta_admin && !resource.admin?
      sign_out resource
      return root_path(alerta: "acesso_negado")
    end

    # Admin vai para o painel, funcionário vai para o check-in
    if resource.admin?
      defined?(painel_path) ? painel_path : root_path
    else
      checkin_path
    end
  end

  private

  def verificar_checkin_turno
    # Só verifica se o funcionário estiver logado e NÃO for admin
    # (Admins geralmente não precisam de check-in de posto de venda)
    if funcionario_signed_in? && !current_funcionario.admin?
      if session[:unidade_atual].blank?
        # Se não estiver no check-in ou saindo, redireciona
        unless request.path == checkin_path || request.path == confirmar_checkin_path || request.path.include?('sign_out')
          redirect_to checkin_path, alert: "Por favor, confirme sua unidade e turno para iniciar as vendas."
        end
      end
    end
  end

  # Métodos auxiliares para usar nas views
  def unidade_trabalho_atual
    session[:unidade_atual] || current_funcionario&.unidade
  end
  helper_method :unidade_trabalho_atual

  def turno_trabalho_atual
    session[:turno_atual] || "Não definido"
  end
  helper_method :turno_trabalho_atual

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :admin, :unidade])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :admin, :unidade])
  end
end