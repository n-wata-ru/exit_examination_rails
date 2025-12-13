class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :coffee_beans, dependent: :destroy
  has_many :tasting_notes, dependent: :destroy

  # Validations
  validates :name, presence: true
end
