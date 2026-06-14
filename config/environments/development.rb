require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Configurações simples primeiro
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.cache_store = :memory_store
  config.active_support.deprecation = :log
  config.assets.quiet = true
  config.action_view.annotate_rendered_view_with_filenames = true

  # Para componentes complexos, usamos o after_initialize
  config.after_initialize do
    # Configurações de Action Controller
    if Rails.root.join("tmp/caching-dev.txt").exist?
      config.action_controller.perform_caching = true
      config.action_controller.enable_fragment_cache_logging = true
      config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
    else
      config.action_controller.perform_caching = false
    end
    config.action_controller.raise_on_missing_callback_actions = true

    # Configurações de Active Record
    config.active_record.migration_error = :page_load
    config.active_record.verbose_query_logs = true
    config.active_record.query_log_tags_enabled = true

    # Configurações de Active Job
    config.active_job.verbose_enqueue_logs = true

    # Configurações de Active Storage
    config.active_storage.service = :local

    # Configurações de Action Mailer
    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.perform_caching = false
    config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

    # Configurações de Action Dispatch
    config.action_dispatch.verbose_redirect_logs = true
  end
end