class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
  # Verifica se na URL de onde o usuário veio (o login) existia o termo 'role=admin'
  veio_da_porta_admin = request.env['HTTP_REFERER']&.include?('role=admin') || params[:role] == 'admin'

  if veio_da_porta_admin && !resource.admin?
    sign_out resource
    # Forçamos a limpeza da sessão e mandamos o alerta pela URL
    return root_path(alerta: "acesso_negado")
  end

  # Se for um admin real ou funcionário no lugar certo, vai para o painel
  # Se o painel não existir, ele vai para a home sem erro
  defined?(painel_path) ? painel_path : root_path
end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :admin])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :admin])
  end
end