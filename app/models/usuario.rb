class Usuario < ApplicationRecord
  belongs_to :rol
  has_many :pagos
  has_secure_password
  has_secure_token :api_token
  
  # Validaciones mejoradas
  validates :nombre, presence: { message: "no puede estar vacío" },
                     uniqueness: { case_sensitive: false, message: "ya está en uso" },
                     length: { minimum: 3, maximum: 50, message: "debe tener entre 3 y 50 caracteres" },
                     format: { with: /\A[a-zA-Z0-9_]+\z/, message: "solo puede contener letras, números y guiones bajos" }
  
  validates :rol, presence: { message: "debe ser seleccionado" }
  
  validates :password, length: { minimum: 8, message: "debe tener al menos 8 caracteres" },
                       format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 
                                message: "debe contener al menos una mayúscula, una minúscula y un número" },
                       allow_nil: true,
                       if: :password_required?
  
  # Validación personalizada para evitar roles inválidos
  validate :rol_debe_ser_valido
  
  private
  
  def password_required?
    password_digest.nil? || password.present?
  end
  
  def rol_debe_ser_valido
    return unless rol
    unless ['administrador', 'suplente'].include?(rol.nombre.downcase)
      errors.add(:rol, "debe ser Administrador o Suplente")
    end
  end
end
