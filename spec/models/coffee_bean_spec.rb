require 'rails_helper'

RSpec.describe CoffeeBean, type: :model do
  describe 'associations' do
    it { should belong_to(:origin).optional }
    it { should have_many(:tasting_notes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    describe 'origin validation' do
      context 'origin_idがnilの場合' do
        it 'originがnilでも有効であること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin_id: nil)
          expect(coffee_bean).to be_valid
        end
      end

      context 'origin_idがpresentの場合' do
        let(:origin) { Origin.create!(country: 'Ethiopia') }

        it 'validなoriginであれば保存できること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin: origin)
          expect(coffee_bean).to be_valid
        end

        it 'origin_idが設定されている場合、有効なoriginが必要であること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin_id: 99999)
          expect(coffee_bean).not_to be_valid
          expect(coffee_bean.errors[:origin]).to be_present
        end
      end
    end
  end

  describe 'dependent destroy' do
    let(:coffee_bean) { CoffeeBean.create!(name: 'Test Bean') }

    it 'destroys associated tasting_notes when coffee_bean is destroyed' do
      user = User.create!(name: 'Test User', email: 'test@example.com', password: 'password')
      tasting_note = coffee_bean.tasting_notes.create!(
        user: user,
        preference_score: 5
      )

      expect { coffee_bean.destroy }.to change { TastingNote.count }.by(-1)
    end
  end
end
