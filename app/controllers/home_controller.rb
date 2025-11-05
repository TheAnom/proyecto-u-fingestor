class HomeController < ApplicationController
  def index
    # Redirigir a dashboard si ya está autenticado
    if session[:usuario_id]
      redirect_to dashboard_path
    end
  end
end
