class UsuariosController < ApplicationController
  before_action :require_login
  before_action -> { require_role('administrador') }, only: [:update, :destroy]

  def update
    @usuario = Usuario.find(params[:id])
    if @usuario.update(usuario_params)
      render json: { 
        success: true, 
        usuario: {
          id: @usuario.id,
          nombre: @usuario.nombre,
          rol_id: @usuario.rol_id,
          rol_nombre: @usuario.rol&.nombre
        }
      }
    else
      field_errors = {}
      @usuario.errors.each do |error|
        field_errors[error.attribute] ||= []
        field_errors[error.attribute] << error.message
      end
      render json: { 
        success: false, 
        errors: @usuario.errors.full_messages,
        field_errors: field_errors
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: ['Usuario no encontrado'] }, status: :not_found
  rescue => e
    render json: { success: false, errors: [e.message] }, status: :internal_server_error
  end

  def destroy
    @usuario = Usuario.find(params[:id])
    if @usuario.destroy
      render json: { success: true }
    else
      render json: { success: false, errors: @usuario.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, errors: ['Usuario no encontrado'] }, status: :not_found
  rescue => e
    render json: { success: false, errors: [e.message] }, status: :internal_server_error
  end

  private

  def usuario_params
    params.require(:usuario).permit(:nombre, :password, :rol_id)
  end
end
