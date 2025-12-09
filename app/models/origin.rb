class Origin < ApplicationRecord
  # Associations
  has_many :coffee_beans, dependent: :destroy

  # Validations
  validates :country, presence: true
end
