Rails.application.routes.draw do
  resources :despesas
  root "home#index"

  # 1. Rota de Logout
  devise_scope :funcionario do
    get '/funcionarios/sign_out' => 'devise/sessions#destroy'
  end

  # 2. Configuração do Devise
  devise_for :funcionarios, skip: [:registrations]

  # 3. Gestão dos Recursos (Funcionários, Produtos, etc.)
  resources :funcionarios
  
  # NOVAS ROTAS DE CHECK-IN (Acrescentadas aqui)
  get '/checkin', to: 'funcionarios#checkin', as: :checkin
  post '/confirmar_checkin', to: 'funcionarios#confirmar_checkin', as: :confirmar_checkin

  resources :cardapio
  
  resources :produtos do
    resources :composicoes, as: 'composicoes', only: [:create]
  end

  resources :estoques, only: [:index, :edit, :update]
  post 'estoques/repor', to: 'estoques#repor', as: :repor_estoque
  resources :composicoes, only: [:destroy]
  
  resources :pedidos do
    member do
      get :comprovante
    end
  end

  resources :movimentacaos
  
  resources :faturamentos do
    get :exportar, on: :collection
  end

  # 4. Painel e Relatórios
  get "painel", to: "home#painel", as: :painel
  get 'faturamento', to: 'faturamentos#index'
  get 'relatorios', to: 'relatorios#index'
  get 'auditoria', to: 'relatorios#auditoria', as: :auditoria
  get 'auditoria/exportar', to: 'relatorios#exportar_auditoria', as: :exportar_auditoria
end