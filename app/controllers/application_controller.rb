class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_session_expiration
  before_action :update_last_activity

  private

  # Require a logged-in usuario (sets redirect if not present)
  def require_login
    unless session[:usuario_id]
      redirect_to login_path, alert: "Debes iniciar sesión"
    end
  end

  # Set the @usuario if session exists (safe find_by)
  def set_usuario
    @usuario = Usuario.find_by(id: session[:usuario_id])
  end

  # Helper to access current user
  def current_user
    @current_user ||= Usuario.find_by(id: session[:usuario_id])
  end
  helper_method :current_user

  def require_role(*roles)
    unless current_user
      redirect_to login_path, alert: "Debes iniciar sesión"
      return
    end
    
    user_role = current_user.rol&.nombre&.downcase
    normalized_roles = roles.map { |r| r.to_s.downcase }
    
    unless user_role && normalized_roles.include?(user_role)
      redirect_to dashboard_path, alert: "No tienes permisos para acceder a esta sección"
    end
  end

  def admin?
    current_user&.rol&.nombre&.downcase == 'administrador'
  end
  helper_method :admin?
  
  def subadmin?
    current_user&.rol&.nombre&.downcase == 'suplente'
  end
  helper_method :subadmin?
  
  def admin_o_subadmin?
    admin? || subadmin?
  end
  helper_method :admin_o_subadmin?

  def session_timeout_seconds
    30.minutes.to_i
  end

  def check_session_expiration
    last = session[:last_seen_at]
    if last && Time.at(last) < session_timeout_seconds.seconds.ago
      reset_session
      redirect_to login_path, alert: "Sesión expirada"
    end
  end

  def update_last_activity
    if session[:usuario_id]
      session[:last_seen_at] = Time.current.to_i
    end
  end
end
