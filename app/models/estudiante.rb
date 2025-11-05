class Estudiante < ApplicationRecord
  belongs_to :grado
  # Cuando se elimina un estudiante, eliminar también sus pagos y asignaciones para mantener integridad
  has_many :pagos, dependent: :destroy
  has_many :asignacion_cursos, dependent: :destroy
  has_many :cursos, through: :asignacion_cursos
  
  # Validaciones mejoradas
  validates :nombre_completo, presence: { message: "no puede estar vacío" },
                              length: { minimum: 3, maximum: 100, message: "debe tener entre 3 y 100 caracteres" },
                              format: { with: /\A[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+\z/, message: "solo puede contener letras y espacios" }
  
  validates :grado, presence: { message: "debe ser seleccionado" }
  
  validates :telefono, format: { with: /\A\d{8,15}\z/, message: "debe contener entre 8 y 15 dígitos" },
                       allow_blank: true
  
  validates :institucion, length: { maximum: 100, message: "no puede exceder 100 caracteres" },
                          allow_blank: true
  
  # Normalizar nombre antes de guardar
  before_save :normalizar_nombre
  
  private
  
  def normalizar_nombre
    self.nombre_completo = nombre_completo.strip.titleize if nombre_completo.present?
  end
end
