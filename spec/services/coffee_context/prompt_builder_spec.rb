require "rails_helper"

RSpec.describe CoffeeContext::PromptBuilder do
  describe "#build" do
    context "ユーザーにコーヒー豆データがない場合" do
      let(:user) { create(:user) }

      subject { described_class.new(user).build }

      it "システムプロンプトにコーヒー専門家の役割が含まれること" do
        expect(subject).to include("コーヒーの専門家アシスタント")
      end

      it "データ未登録のメッセージが含まれること" do
        expect(subject).to include("まだコーヒー豆のデータを登録していません")
      end

      it "コーヒー豆データセクションが含まれないこと" do
        expect(subject).not_to include("【ユーザーのコーヒー豆データ】")
      end
    end

    context "ユーザーにコーヒー豆データがある場合" do
      let(:user) { create(:user) }
      let(:origin) { Origin.create!(country: "エチオピア", region: "イルガチェフェ", farm_name: "コケ農園") }
      let(:shop) { Shop.create!(name: "Blue Bottle Coffee", address: "東京都港区") }
      let!(:bean) do
        create(:coffee_bean,
          user: user,
          name: "エチオピア イルガチェフェ",
          variety: "ゲイシャ",
          process: "ウォッシュド",
          roast_level: "浅煎り",
          notes: "フローラルな香り",
          origin: origin
        )
      end
      let!(:tasting_note) do
        TastingNote.create!(
          user: user,
          coffee_bean: bean,
          shop: shop,
          brew_method: "ハンドドリップ",
          preference_score: 5,
          acidity_score: 4,
          bitterness_score: 2,
          sweetness_score: 4,
          taste_notes: "ジャスミンのような香り、柑橘系の酸味"
        )
      end

      subject { described_class.new(user).build }

      it "コーヒー豆データセクションが含まれること" do
        expect(subject).to include("【ユーザーのコーヒー豆データ】")
      end

      it "コーヒー豆名が含まれること" do
        expect(subject).to include("エチオピア イルガチェフェ")
      end

      it "品種が含まれること" do
        expect(subject).to include("品種: ゲイシャ")
      end

      it "精製方法が含まれること" do
        expect(subject).to include("精製方法: ウォッシュド")
      end

      it "焙煎度が含まれること" do
        expect(subject).to include("焙煎度: 浅煎り")
      end

      it "産地情報が含まれること" do
        expect(subject).to include("エチオピア")
        expect(subject).to include("イルガチェフェ")
        expect(subject).to include("コケ農園")
      end

      it "テイスティングノートが含まれること" do
        expect(subject).to include("ハンドドリップ")
        expect(subject).to include("好み: 5/5")
        expect(subject).to include("酸味: 4/5")
        expect(subject).to include("苦味: 2/5")
        expect(subject).to include("甘味: 4/5")
        expect(subject).to include("ジャスミンのような香り")
      end

      it "ショップ情報が含まれること" do
        expect(subject).to include("Blue Bottle Coffee")
        expect(subject).to include("東京都港区")
      end
    end

    context "コーヒー豆にオプショナルフィールドがない場合" do
      let(:user) { create(:user) }
      let!(:bean) do
        create(:coffee_bean,
          user: user,
          name: "シンプル豆",
          variety: nil,
          process: nil,
          roast_level: nil,
          notes: nil,
          origin: nil
        )
      end

      subject { described_class.new(user).build }

      it "豆名は含まれること" do
        expect(subject).to include("シンプル豆")
      end

      it "品種ラベルが含まれないこと" do
        expect(subject).not_to include("品種:")
      end

      it "産地ラベルが含まれないこと" do
        expect(subject).not_to include("産地:")
      end
    end

    context "大量のコーヒー豆データがある場合" do
      let(:user) { create(:user) }

      before do
        55.times do |i|
          create(:coffee_bean, user: user, name: "コーヒー豆#{i}")
        end
      end

      subject { described_class.new(user).build }

      it "MAX_BEANS以下のデータが含まれること" do
        bean_count = subject.scan(/--- コーヒー豆 \d+:/).count
        expect(bean_count).to eq(CoffeeContext::PromptBuilder::MAX_BEANS)
      end
    end

    context "ショップ情報がないテイスティングノートの場合" do
      let(:user) { create(:user) }
      let!(:bean) { create(:coffee_bean, user: user) }
      let!(:tasting_note) do
        TastingNote.create!(
          user: user,
          coffee_bean: bean,
          shop: nil,
          brew_method: "エスプレッソ",
          preference_score: 4,
          acidity_score: 3,
          bitterness_score: 4,
          sweetness_score: 2,
          taste_notes: "チョコレートのような風味"
        )
      end

      subject { described_class.new(user).build }

      it "購入店ラベルが含まれないこと" do
        expect(subject).not_to include("購入店:")
      end

      it "テイスティングデータは含まれること" do
        expect(subject).to include("エスプレッソ")
        expect(subject).to include("チョコレートのような風味")
      end
    end
  end
end
