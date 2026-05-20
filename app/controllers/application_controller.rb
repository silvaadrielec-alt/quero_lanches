class ApplicationController < ActionController::Base
  # 1. VERIFICAÇÃO DE SETUP (Deve ser a primeira de todas)
  before_action :verificar_se_precisa_setup

  # 2. OUTRAS VERIFICAÇÕES
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :verificar_checkin_turno, unless: :devise_controller?

  def after_sign_in_path_for(resource)
    veio_da_porta_admin = request.env['HTTP_REFERER']&.include?('role=admin') || params[:role] == 'admin'

    if veio_da_porta_admin && !resource.admin?
      sign_out resource
      return root_path(alerta: "acesso_negado")
    end

    checkin_path
  end

  private

  # NOVO MÉTODO: Sensor de Primeiro Acesso
  def verificar_se_precisa_setup
    # Se não houver NINGUÉM no banco, e não estivermos já no setup ou no devise (login), redireciona
    if !Funcionario.exists? && controller_name != 'setup' && !devise_controller?
      redirect_to primeiro_acesso_path
    end
  end

  def verificar_checkin_turno
    if funcionario_signed_in?
      if session[:unidade_atual].blank?
        unless request.path == checkin_path || request.path == confirmar_checkin_path || request.path.include?('sign_out')
          redirect_to checkin_path, alert: "Confirmação Necessária: Selecione a unidade e o turno de atuação."
        end
      end
    end
  end

  # Métodos auxiliares para usar nas views
  def unidade_trabalho_atual
    session[:unidade_atual] || "Não selecionada"
  end
  helper_method :unidade_trabalho_atual

  def turno_trabalho_atual
    session[:turno_atual] || "Não definido"
  end
  helper_method :turno_trabalho_atual

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :admin, :unidade, :turno, :cargo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :admin, :unidade, :turno, :cargo])
  end
end