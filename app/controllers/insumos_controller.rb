class InsumosController < ApplicationController
  before_action :authenticate_funcionario!
  before_action :verificar_admin, only: [:destroy, :edit, :update]
  before_action :set_insumo, only: %i[ show edit update destroy ]

  def index
    if params[:query].present?
      termo = "%#{params[:query].downcase}%"
      @insumos = Insumo.where("lower(nome) LIKE ?", termo)
    else
      @insumos = Insumo.all
    end
  end

  def show
    @referencias = ReferenciaRendimento.all
  end

  def new
    @insumo = Insumo.new
    @referencias = ReferenciaRendimento.all
  end

  def edit
    @referencias = ReferenciaRendimento.all
  end

  def create
    @insumo = Insumo.new(insumo_params)

    if @insumo.save
      redirect_to insumos_path, notice: "Insumo cadastrado com sucesso!"
    else
      @referencias = ReferenciaRendimento.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @insumo.update(insumo_params)
      redirect_to insumos_path, notice: "Insumo atualizado com sucesso!"
    else
      @referencias = ReferenciaRendimento.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Garante o tratamento visual se o Rails bloquear a exclusão por segurança de chaves primárias
    if @insumo.destroy
      flash[:notice] = "Insumo excluído com sucesso!"
    else
      flash[:alert] = "Não é possível excluir: este insumo está ativo na composição de fichas técnicas do cardápio."
    end
    
    redirect_to insumos_path, status: :see_other
  end

  private

  def set_insumo
    @insumo = Insumo.find(params[:id])
  end

  # 🌟 PARÂMETROS CORRIGIDOS: Inclusão dos limites de filiais para gravação correta 
  # dos alertas mínimos de estoque e remoção de redundâncias de venda direta.
  def insumo_params
    params.require(:insumo).permit(
      :nome, :preco_custo, :preco_venda, :estoque_centro, :estoque_pavilhao_novo, 
      :estoque_pavilhao_antigo, :limite_centro, :limite_pavilhao_novo, 
      :limite_pavilhao_antigo, :media_unidades_kg, :unidade_medida
    )
  end

  def verificar_admin
    unless current_funcionario.admin?
      redirect_to root_path, alert: "Acesso negado! Você não tem permissão de Administrador."
    end
  end
end