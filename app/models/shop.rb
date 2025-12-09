class Shop < ApplicationRecord
  # Associations
  has_many :tasting_notes, dependent: :nullify

  # Validations
  validates :name, presence: true
end
