require "rails_helper"

RSpec.describe OpenAi::VisionService do
  subject(:service) { described_class.new }

  let(:client) { instance_double(OpenAI::Client) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(client)
  end

  describe "#extract_coffee_info" do
    it "画像解析結果のJSONを抽出できること" do
      response_content = {
        name: "エチオピア イルガチェフェ",
        origin_country: "Ethiopia",
        variety: "ゲイシャ",
        process: "ウォッシュド",
        roast_level: "浅煎り",
        notes: "フローラルな香り"
      }.to_json

      allow(client).to receive(:chat).and_return(
        { "choices" => [ { "message" => { "content" => response_content } } ] }
      )

      result = service.extract_coffee_info(image_data_url: "data:image/png;base64,xxx")

      expect(result).to eq(
        "name" => "エチオピア イルガチェフェ",
        "origin_country" => "Ethiopia",
        "variety" => "ゲイシャ",
        "process" => "ウォッシュド",
        "roast_level" => "浅煎り",
        "notes" => "フローラルな香り"
      )
    end

    it "読み取れなかった項目は空文字列になること" do
      allow(client).to receive(:chat).and_return(
        { "choices" => [ { "message" => { "content" => { name: "テスト" }.to_json } } ] }
      )

      result = service.extract_coffee_info(image_data_url: "data:image/png;base64,xxx")

      expect(result["name"]).to eq("テスト")
      expect(result["origin_country"]).to eq("")
    end

    it "APIエラー時は例外を再送出すること" do
      allow(client).to receive(:chat).and_raise(StandardError.new("API error"))

      expect {
        service.extract_coffee_info(image_data_url: "data:image/png;base64,xxx")
      }.to raise_error(StandardError, "API error")
    end
  end
end
