class CoffeeBean < ApplicationRecord
  # Associations
  belongs_to :origin
  has_many :tasting_notes, dependent: :destroy

  # Validations
  validates :name, presence: true
end
