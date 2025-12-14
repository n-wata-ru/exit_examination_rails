require 'rails_helper'

RSpec.describe TastingNote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:coffee_bean) }
    it { should belong_to(:shop).optional }
  end

  describe 'validations' do
    describe 'preference_score' do
      it 'nilを許容' do
        tasting_note = build_tasting_note(preference_score: nil)
        expect(tasting_note).to be_valid
      end

      it '1以上の値を許容' do
        tasting_note = build_tasting_note(preference_score: 1)
        expect(tasting_note).to be_valid
      end

      it '5以下の値を許容' do
        tasting_note = build_tasting_note(preference_score: 5)
        expect(tasting_note).to be_valid
      end

      it '0を拒否' do
        tasting_note = build_tasting_note(preference_score: 0)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:preference_score]).to be_present
      end

      it '6を拒否' do
        tasting_note = build_tasting_note(preference_score: 6)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:preference_score]).to be_present
      end

      it '小数を拒否' do
        tasting_note = build_tasting_note(preference_score: 3.5)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:preference_score]).to be_present
      end
    end

    describe 'acidity_score' do
      it 'nilを許容' do
        tasting_note = build_tasting_note(acidity_score: nil)
        expect(tasting_note).to be_valid
      end

      it '1以上の値を許容' do
        tasting_note = build_tasting_note(acidity_score: 1)
        expect(tasting_note).to be_valid
      end

      it '5以下の値を許容' do
        tasting_note = build_tasting_note(acidity_score: 5)
        expect(tasting_note).to be_valid
      end

      it '0を拒否' do
        tasting_note = build_tasting_note(acidity_score: 0)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:acidity_score]).to be_present
      end

      it '6を拒否' do
        tasting_note = build_tasting_note(acidity_score: 6)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:acidity_score]).to be_present
      end

      it '小数を拒否' do
        tasting_note = build_tasting_note(acidity_score: 2.5)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:acidity_score]).to be_present
      end
    end

    describe 'bitterness_score' do
      it 'nilを許容' do
        tasting_note = build_tasting_note(bitterness_score: nil)
        expect(tasting_note).to be_valid
      end

      it '1以上の値を許容' do
        tasting_note = build_tasting_note(bitterness_score: 1)
        expect(tasting_note).to be_valid
      end

      it '5以下の値を許容' do
        tasting_note = build_tasting_note(bitterness_score: 5)
        expect(tasting_note).to be_valid
      end

      it '0を拒否' do
        tasting_note = build_tasting_note(bitterness_score: 0)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:bitterness_score]).to be_present
      end

      it '6を拒否' do
        tasting_note = build_tasting_note(bitterness_score: 6)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:bitterness_score]).to be_present
      end

      it '小数を拒否' do
        tasting_note = build_tasting_note(bitterness_score: 4.5)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:bitterness_score]).to be_present
      end
    end

    describe 'sweetness_score' do
      it 'nilを許容' do
        tasting_note = build_tasting_note(sweetness_score: nil)
        expect(tasting_note).to be_valid
      end

      it '1以上の値を許容' do
        tasting_note = build_tasting_note(sweetness_score: 1)
        expect(tasting_note).to be_valid
      end

      it '5以下の値を許容' do
        tasting_note = build_tasting_note(sweetness_score: 5)
        expect(tasting_note).to be_valid
      end

      it '0を拒否' do
        tasting_note = build_tasting_note(sweetness_score: 0)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:sweetness_score]).to be_present
      end

      it '6を拒否' do
        tasting_note = build_tasting_note(sweetness_score: 6)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:sweetness_score]).to be_present
      end

      it '小数を拒否' do
        tasting_note = build_tasting_note(sweetness_score: 1.5)
        expect(tasting_note).not_to be_valid
        expect(tasting_note.errors[:sweetness_score]).to be_present
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
