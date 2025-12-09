require 'rails_helper'

RSpec.describe Origin, type: :model do
  describe 'associations' do
    it { should have_many(:coffee_beans).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:country) }
  end
end
