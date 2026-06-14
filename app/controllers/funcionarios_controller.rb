class FuncionariosController < ApplicationController
  before_action :authenticate_funcionario!
  # Liberamos o checkin e o confirmar_checkin para todos os funcionários!
  before_action :verificar_admin, except: [:new, :create, :checkin, :confirmar_checkin]
  before_action :set_funcionario, only: %i[ show edit update destroy ]

  def index
    @funcionarios = Funcionario.all
  end

  # --- MÉTODOS DE CHECK-IN ---

  def checkin
    # Apenas renderiza a view app/views/funcionarios/checkin.html.erb
  end

  def confirmar_checkin
  # O params[:unidade_id] agora vem como string ("2"), precisamos converter para integer
  unidade_id = params[:unidade_id].to_i 
  turno = params[:turno]
  codigo = params[:codigo_gerente]

  # --- SENSOR DE COMPLIANCE DE TURNO E UNIDADE ---
  # Comparamos o ID da unidade selecionada com o ID da unidade habitual do funcionário
  # Comparamos o turno com a string gravada no funcionário
  if unidade_id.to_i != current_funcionario.unidade_id || turno != current_funcionario.turno
    gerente_autorizou = Funcionario.where(admin: true, codigo_autorizacao: codigo).exists?
    
    unless gerente_autorizou
      redirect_to checkin_path, alert: "Código de autorização inválido ou ausente! É necessária autorização do Gerente para alterar posto ou turno."
      return 
    end
  end

  # Se estiver tudo certo, salva na sessão. 
  # Recomendação: Salve o ID, pois é o identificador único e imutável.
  session[:unidade_atual] = unidade_id
  session[:turno_atual] = turno
  
  redirect_to root_path, notice: "Entrada confirmada! Bom trabalho, #{current_funcionario.nome}."
end

  # --- FIM DOS MÉTODOS DE CHECK-IN ---

  def show
  end

  def new
    @funcionario = Funcionario.new
  end

  def edit
  end

  def create
    @funcionario = Funcionario.new(funcionario_params)
    if @funcionario.save
      redirect_to funcionarios_path, notice: "Funcionário cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    params_para_atualizar = funcionario_params
    
    # Se a senha foi deixada em branco, remove os campos para não resetar a senha do usuário
    if params_para_atualizar[:password].blank?
      params_para_atualizar.delete(:password)
      params_para_atualizar.delete(:password_confirmation)
    end

    # FORÇA O SALVAMENTO: O 'update' normal pode falhar por causa das restrições do Devise.
    # Se não houver senha nova, usamos 'update_without_password' para salvar os dados cadastrais.
    if params_para_atualizar[:password].nil?
      sucesso = @funcionario.update_without_password(params_para_atualizar)
    else
      sucesso = @funcionario.update(params_para_atualizar)
    end

    if sucesso
      redirect_to funcionarios_path, notice: "Informações atualizadas com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @funcionario.destroy
    redirect_to funcionarios_path, notice: "Funcionário excluído com sucesso!"
  end

  private

  def set_funcionario
    @funcionario = Funcionario.find(params[:id])
  end

  def funcionario_params
    # ATUALIZADO: Adicionado :telefone, :data_admissao e :data_demissao para persistência segura
    params.require(:funcionario).permit(
      :nome, :data_nascimento, :email, :password, :password_confirmation, :admin, 
      :unidade_id, :turno, :cargo, :codigo_autorizacao,
      :telefone, :data_admissao, :data_demissao, :cpf
    )
  end

  def verificar_admin
    if current_funcionario.nil? || current_funcionario.admin != true
      redirect_to root_path, alert: "Acesso restrito apenas para administradores!"
    end
  end
end