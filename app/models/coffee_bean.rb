class CoffeeBean < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :origin, optional: true
  has_many :tasting_notes, dependent: :destroy
  has_one_attached :image

  # Validations
  validates :name, presence: true
  validates :user, presence: true

  # origin_idがある場合のみ、Originが存在することを確認
  validates :origin, presence: true, if: -> { origin_id.present? }
end
