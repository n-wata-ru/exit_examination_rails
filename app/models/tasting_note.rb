class TastingNote < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :coffee_bean
  belongs_to :shop, optional: true

  # Validations
  validates :preference_score, presence: true
  validates :acidity_score, presence: true
  validates :bitterness_score, presence: true
  validates :sweetness_score, presence: true
  validates :brew_method, presence: true
end
