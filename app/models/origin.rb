class Origin < ApplicationRecord
  # Associations
  has_many :coffee_beans, dependent: :destroy

  # Validations
  validates :country, presence: true
  validates :geonames_id, uniqueness: true, allow_nil: true
  validates :latitude, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }, allow_nil: true
  validates :longitude, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }, allow_nil: true

  # Scopes
  scope :with_coordinates, -> { where.not(latitude: nil, longitude: nil) }

  # 表示用メソッド
  def display_name
    [ country, region ].compact.join(" - ")
  end
end
