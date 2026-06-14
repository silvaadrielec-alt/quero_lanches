Rails.application.routes.draw do
  root "home#index"

  # 1. Autenticação e Configuração
  get 'primeiro_acesso', to: 'setup#index', as: :primeiro_acesso
  post 'criar_primeiro_admin', to: 'setup#create', as: :criar_primeiro_admin
  
  devise_scope :funcionario do
    get '/funcionarios/sign_out' => 'devise/sessions#destroy'
  end
  devise_for :funcionarios, skip: [:registrations]

  # 2. Gestão de Pessoal e Check-in
  resources :funcionarios
  get '/checkin', to: 'funcionarios#checkin', as: :checkin
  post '/confirmar_checkin', to: 'funcionarios#confirmar_checkin', as: :confirmar_checkin

  # 3. Módulos de Operação e Estoque
  resources :cardapio
  resources :produtos
  resources :insumos
  resources :despesas

  resources :estoques, only: [:index, :edit, :update] do
    collection do
      get :lote
      post :processar_lote
      get :auditoria # Integrado aqui para manter a lógica de estoque unificada
      post :transferir # <--- COLOQUE AQUI
    end
  end
  post 'estoques/repor', to: 'estoques#repor', as: :repor_estoque
  
  resources :composicoes, only: [:create, :destroy], as: 'composicoes' do
    collection do
      get :gerenciar
    end
  end
  
  resources :pedidos do
    collection do
      post :adicionar_item
      post :adicionar_adicional
    end
    member do
      get :comprovante
    end
  end

  resources :movimentacaos, only: [:index, :show]

 
  # 4. Módulos de Inteligência Financeira e Auditoria
  resources :faturamentos, only: [:index] do
    get :exportar, on: :collection
  end
  
  resources :relatorio_financeiro, only: [:index]

  get 'fluxo_de_caixa', to: 'fluxo_de_caixa#index', as: :fluxo_de_caixa
  
  resources :auditorias, only: [:index]
  get 'relatorios', to: 'relatorios#index'
  get 'auditoria/exportar', to: 'relatorios#exportar_auditoria', as: :exportar_auditoria

  # 5. Segurança e Notificações
  post 'autorizar_gerente', to: 'application#autorizar_gerente'
  
  resources :notificacaos, only: [:index] do
    member do
      patch :marcar_como_lida
    end
  end

  # Dashboard principal
  get "painel", to: "home#painel", as: :painel
end

