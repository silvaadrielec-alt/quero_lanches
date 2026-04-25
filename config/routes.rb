Rails.application.routes.draw do
  root "home#index"

  # 1. Rota de Logout (Tem que vir antes de resources para não dar erro de ID)
  devise_scope :funcionario do
    get '/funcionarios/sign_out' => 'devise/sessions#destroy'
  end

  # 2. Configuração do Devise
  devise_for :funcionarios, skip: [:registrations]

  # 3. Gestão dos Recursos (Funcionários, Produtos, etc.)
  resources :funcionarios
  resources :produtos
  resources :clientes
  resources :pedidos
  resources :movimentacaos

  # 4. Painel e Relatórios
  get "painel", to: "home#painel", as: :painel
  get "relatorios/index", to: "relatorios#index", as: :relatorios
end