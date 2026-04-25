 class HomeController < ApplicationController
  # Esta linha diz para não usar o layout padrão (com cabeçalho) na index
  layout "application", except: [:index]

  def index
    if funcionario_signed_in?
      render :painel
    else
      # Quando renderizar a index, ele virá sem o cabeçalho global
      render :index
    end
  end
end
