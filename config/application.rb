require_relative "boot"

# Isto carrega todos os componentes do Rails (ActiveRecord, ActionController, etc.)
require "rails/all"

# Requer as gems listadas no Gemfile
Bundler.require(*Rails.groups)

module QueroLanches
  class Application < Rails::Application
    # Carrega os padrões da versão 8.1
    config.load_defaults 8.1

    # Configurações de autocarga de código
    config.autoload_lib(ignore: %w[assets tasks])
    
    # Configurações de localização e tempo
    config.i18n.default_locale = "pt-BR"
    config.time_zone = 'America/Bahia'
  end
end