require 'rails_helper'

RSpec.describe CoffeeBean, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:origin).optional }
    it { should have_many(:tasting_notes).dependent(:destroy) }
    it { should have_one_attached(:image) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:user) }

    describe 'origin validation' do
      let(:user) { FactoryBot.create(:user) }

      context 'origin_idがnilの場合' do
        it 'originがnilでも有効であること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin_id: nil, user: user)
          expect(coffee_bean).to be_valid
        end
      end

      context 'origin_idがpresentの場合' do
        let(:origin) { Origin.create!(country: 'Ethiopia') }

        it 'validなoriginであれば保存できること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin: origin, user: user)
          expect(coffee_bean).to be_valid
        end

        it 'origin_idが設定されている場合、有効なoriginが必要であること' do
          coffee_bean = CoffeeBean.new(name: 'Test Bean', origin_id: 99999, user: user)
          expect(coffee_bean).not_to be_valid
          expect(coffee_bean.errors[:origin]).to be_present
        end
      end
    end
  end

  describe 'dependent destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:coffee_bean) { FactoryBot.create(:coffee_bean, user: user) }

    it 'coffee_beanが削除されたら関連するtasting_notesも削除されること' do
      coffee_bean.tasting_notes.create!(
        user: user,
        preference_score: 5,
        acidity_score: 4,
        bitterness_score: 3,
        sweetness_score: 4,
        brew_method: 'Pour Over'
      )

      expect { coffee_bean.destroy }.to change { TastingNote.count }.by(-1)
    end
  end
end
