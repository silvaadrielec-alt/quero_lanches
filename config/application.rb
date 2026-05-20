require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QueroLanches
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    
    # Configurações de Idioma e Horário
    config.i18n.default_locale = "pt-BR"
    config.time_zone = 'Brasilia'
    
    # FORÇA O ACTIVE RECORD A USAR O HORÁRIO DA BAHIA/BRASÍLIA NO BANCO DE DADOS
     config.active_record.default_timezone = :local

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")
  end
end