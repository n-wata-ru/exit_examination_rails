# == Schema Information
#
# Table name: users
#
#  id: integer,
#  created_at: datetime,
#  email: string,
#  encrypted_password: string,
#  name: string,
#  remember_created_at: datetime,
#  reset_password_sent_at: datetime,
#  reset_password_token: string,
#  updated_at: datetime)
#
#

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "admin-#{n}" }
    sequence(:email) { |n| "admin-#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
