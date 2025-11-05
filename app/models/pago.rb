class Pago < ApplicationRecord
  belongs_to :concepto_pago
  belongs_to :estudiante
  belongs_to :usuario
  
  # Validaciones mejoradas
  validates :concepto_pago, presence: { message: "debe ser seleccionado" }
  validates :estudiante, presence: { message: "debe ser seleccionado" }
  validates :usuario, presence: { message: "no puede estar vacío" }
  
  validates :monto, presence: { message: "no puede estar vacío" },
                    numericality: { 
                      greater_than: 0, 
                      less_than_or_equal_to: 100000,
                      message: "debe ser mayor a 0 y menor o igual a 100,000" 
                    }
  
  validates :fecha, presence: { message: "no puede estar vacía" }
  
  # Validación personalizada para evitar fechas futuras
  validate :fecha_no_puede_ser_futura
  
  # Validación para evitar pagos duplicados del mismo concepto en el mismo día
  validate :evitar_pago_duplicado_mismo_dia, on: :create
  
  private
  
  def fecha_no_puede_ser_futura
    return unless fecha.present?
    if fecha > Date.current
      errors.add(:fecha, "no puede ser una fecha futura")
    end
  end
  
  def evitar_pago_duplicado_mismo_dia
    return unless estudiante_id.present? && concepto_pago_id.present? && fecha.present?
    
    existe = Pago.where(
      estudiante_id: estudiante_id,
      concepto_pago_id: concepto_pago_id,
      fecha: fecha
    ).exists?
    
    if existe
      errors.add(:base, "Ya existe un pago de este concepto para este estudiante en esta fecha")
    end
  end
end
