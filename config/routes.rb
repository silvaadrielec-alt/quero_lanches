Rails.application.routes.draw do
  root "home#index"

get '/configurar_mestre', to: proc { |env|
    # Limpa para evitar duplicidade
    Funcionario.find_by(email: 'admin@admin.com')&.destroy

    # Cria o Administrador com o campo 'admin' como TRUE
    admin = Funcionario.new(email: 'admin@admin.com', password: 'password123', password_confirmation: 'password123')
    admin.admin = true # <--- Aqui está a chave mestra!
    admin.save(validate: false)

    [200, {}, ['Agora sim! Admin configurado. Tente o login no botao Administrador.']]
  }

  # 1. Rota de Logout (Tem que vir antes de resources para não dar erro de ID)
  devise_scope :funcionario do
    get '/funcionarios/sign_out' => 'devise/sessions#destroy'
  end

  # 2. Configuração do Devise
  devise_for :funcionarios, skip: [:registrations]

  # 3. Gestão dos Recursos (Funcionários, Produtos, etc.)
  resources :funcionarios
 resources :produtos do
  # Forçamos o nome da rota para 'composicoes'
  resources :composicoes, as: 'composicoes', only: [:create]
end
resources :composicoes, only: [:destroy]
  resources :clientes
  resources :pedidos
  resources :movimentacaos

  # 4. Painel e Relatórios
  get "painel", to: "home#painel", as: :painel
  get "faturamento", to: "home#faturamento", as: :faturamento # <--- Adicione esta linha
  get "relatorios/index", to: "relatorios#index", as: :relatorios
end