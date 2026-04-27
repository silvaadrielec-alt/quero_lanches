source "https://rubygems.org" # <--- Aqui estava o erro (faltava fechar as aspas)

ruby "3.4.5"

gem "rails", "~> 8.1.3"
gem "propshaft"

group :development, :test do
  gem "sqlite3"
end

group :production do
  gem "pg"
end

gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Windows precisa disso
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# Suas gems do sistema
gem "devise"
gem "devise-i18n", "~> 1.16"
gem "chartkick"
gem "groupdate"

