require 'rails_helper'

RSpec.describe Origin, type: :model do
  describe 'associations' do
    it { should have_many(:coffee_beans).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:country) }

    describe 'geonames_id' do
      it 'nilを許容' do
        origin = Origin.new(country: 'Japan', geonames_id: nil)
        expect(origin).to be_valid
      end

      it '一意性の検証（値が存在する場合）' do
        Origin.create!(country: 'Japan', geonames_id: 123)
        duplicate = Origin.new(country: 'Brazil', geonames_id: 123)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:geonames_id]).to include('はすでに存在します')
      end
    end

    describe 'latitude' do
      it 'nilを許容' do
        origin = Origin.new(country: 'Japan', latitude: nil)
        expect(origin).to be_valid
      end

      it '-90以上の値を許容' do
        origin = Origin.new(country: 'Japan', latitude: -90)
        expect(origin).to be_valid
      end

      it '90以下の値を許容' do
        origin = Origin.new(country: 'Japan', latitude: 90)
        expect(origin).to be_valid
      end

      it '-90未満の値を拒否' do
        origin = Origin.new(country: 'Japan', latitude: -91)
        expect(origin).not_to be_valid
      end

      it '90より大きい値を拒否' do
        origin = Origin.new(country: 'Japan', latitude: 91)
        expect(origin).not_to be_valid
      end
    end

    describe 'longitude' do
      it 'nilを許容' do
        origin = Origin.new(country: 'Japan', longitude: nil)
        expect(origin).to be_valid
      end

      it '-180以上の値を許容' do
        origin = Origin.new(country: 'Japan', longitude: -180)
        expect(origin).to be_valid
      end

      it '180以下の値を許容' do
        origin = Origin.new(country: 'Japan', longitude: 180)
        expect(origin).to be_valid
      end

      it '-180未満の値を拒否' do
        origin = Origin.new(country: 'Japan', longitude: -181)
        expect(origin).not_to be_valid
      end

      it '180より大きい値を拒否' do
        origin = Origin.new(country: 'Japan', longitude: 181)
        expect(origin).not_to be_valid
      end
    end
  end

  describe '#display_name' do
    it 'regionがnilでも値を返すか' do
      origin = Origin.new(country: 'Japan', region: nil)
      expect(origin.display_name).to eq('Japan')
    end

    it 'countryとregionの両方が存在する場合にそれらを返すか' do
      origin = Origin.new(country: 'Ethiopia', region: 'Yirgacheffe')
      expect(origin.display_name).to eq('Ethiopia - Yirgacheffe')
    end

    it 'regionが空文字の場合にcountryを返すか' do
      origin = Origin.new(country: 'Brazil', region: '')
      expect(origin.display_name).to eq('Brazil')
    end
  end
end
