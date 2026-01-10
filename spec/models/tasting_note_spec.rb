require 'rails_helper'

RSpec.describe TastingNote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:coffee_bean) }
    it { should belong_to(:shop).optional }
  end

  describe 'validations' do
    describe 'preference_score' do
      it 'nilを許容しない' do
        tasting_note = build_tasting_note(preference_score: nil)
        expect(tasting_note).to_not be_valid
      end
    end

    describe 'acidity_score' do
      it 'nilを許容しない' do
        tasting_note = build_tasting_note(acidity_score: nil)
        expect(tasting_note).to_not be_valid
      end
    end

    describe 'bitterness_score' do
      it 'nilを許容しない' do
        tasting_note = build_tasting_note(bitterness_score: nil)
        expect(tasting_note).to_not be_valid
      end
    end

    describe 'sweetness_score' do
      it 'nilを許容しない' do
        tasting_note = build_tasting_note(sweetness_score: nil)
        expect(tasting_note).to_not be_valid
      end
    end
  end

  private

  def build_tasting_note(attributes = {})
    user = FactoryBot.create(:user)
    coffee_bean = FactoryBot.create(:coffee_bean, user: user)
    TastingNote.new(
      user: user,
      coffee_bean: coffee_bean,
      **attributes
    )
  end
end
