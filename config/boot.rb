ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Só carrega o bootsnap se NÃO estiver no ambiente de produção do Railway
require "bootsnap/setup" if ENV["RAILS_ENV"] != "production"

# GAMBIARRA DO RAILWAY: Força a migração do banco antes do servidor web iniciar
if ENV["RAILS_ENV"] == "production"
  puts "===[ Railway ] Detectado ambiente de produção. Rodando db:migrate... ==="
  system("bundle exec rails db:migrate")
end