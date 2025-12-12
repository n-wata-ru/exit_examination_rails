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

  # 表示用メソッド：compactでnilを取り除き、rejectで空文字を取り除き、joinで結合
  # 取り除かれると["Brazil"].join(" - ") => "Brazil"となり連結がされない
  def display_name
    [ country, region ].compact.reject(&:blank?).join(" - ")
  end
end
