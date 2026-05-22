Rails.application.routes.draw do
  # Rotas de Primeiro Acesso e Configuração Inicial
  get 'primeiro_acesso', to: 'setup#index', as: :primeiro_acesso
  post 'criar_primeiro_admin', to: 'setup#create', as: :criar_primeiro_admin
  
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
  
  # Novas rotas de Check-in
  get '/checkin', to: 'funcionarios#checkin', as: :checkin
  post '/confirmar_checkin', to: 'funcionarios#confirmar_checkin', as: :confirmar_checkin

  resources :cardapio
  
  # MODIFICADO: Removido o sub-recurso antigo de composições daqui de dentro
  resources :produtos

  resources :estoques, only: [:index, :edit, :update] do
    collection do
      get :lote           # Tela da entrada por lote
      post :processar_lote   # Ação que salva o lote inteiro
    end
  end
  post 'estoques/repor', to: 'estoques#repor', as: :repor_estoque
  
  # ATUALIZADO: Nova rota centralizada para gerenciar fichas técnicas em uma única tela
  resources :composicoes, only: [:create, :destroy], as: 'composicoes' do
    collection do
      get :gerenciar      # Rota para a nova tela de gerenciamento
    end
  end
  
  resources :pedidos do
    member do
      get :comprovante
    end
  end

  resources :movimentacaos

  # Rota global para validação dinâmica de gerente no sistema inteiro
  post 'autorizar_gerente', to: 'application#autorizar_gerente'
  
  resources :faturamentos do
    get :exportar, on: :collection
  end

  # 4. Painel e Relatórios
  get "painel", to: "home#painel", as: :painel
  get 'faturamento', to: 'faturamentos#index'
  
  # Nova Rota do Fluxo de Caixa corrigida
  get 'fluxo_de_caixa', to: 'fluxo_de_caixa#index', as: :fluxo_de_caixa
  
  get 'relatorios', to: 'relatorios#index'
  get 'auditoria', to: 'relatorios#auditoria', as: :auditoria
  get 'auditoria/exportar', to: 'relatorios#exportar_auditoria', as: :exportar_auditoria
end