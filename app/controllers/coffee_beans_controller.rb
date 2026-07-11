class CoffeeBeansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_coffee_bean, only: %i[show edit update destroy]
  before_action :set_origins, only: %i[new create edit update]

  def index
    @coffee_beans = current_user.coffee_beans.includes(:origin)
  end

  def show
  end

  def new
    @coffee_bean = current_user.coffee_beans.build
  end

  def create
    @coffee_bean = current_user.coffee_beans.build(coffee_bean_params)

    if @coffee_bean.save
      redirect_to coffee_beans_path, notice: "コーヒー豆を登録しました"
    else
      @origins = Origin.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

def update
  if @coffee_bean.update(coffee_bean_params)
    redirect_to coffee_bean_path(@coffee_bean), notice: "コーヒー豆を更新しました"
  else
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    @coffee_bean.destroy
    redirect_to coffee_beans_path, notice: "コーヒー豆を削除しました"
  end

  def extract_from_image
    image_file = params.require(:image)
    data_url = "data:#{image_file.content_type};base64,#{Base64.strict_encode64(image_file.read)}"

    info = OpenAi::VisionService.new.extract_coffee_info(image_data_url: data_url)
    info["origin_id"] = find_origin_id(info["origin_country"])

    render json: info
  rescue ActionController::ParameterMissing
    render json: { error: "画像が選択されていません" }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("Image recognition failed: #{e.message}")
    render json: { error: "画像の解析に失敗しました" }, status: :unprocessable_entity
  end

  private

  def find_origin_id(country)
    return nil if country.blank?

    Origin.where("LOWER(country) = ?", country.downcase).first&.id
  end

  def set_coffee_bean
    @coffee_bean = current_user.coffee_beans.find(params[:id])
  end

  def set_origins
    @origins = Origin.all
  end

  def coffee_bean_params
    params.require(:coffee_bean).permit(
      :name,
      :origin_id,
      :variety,
      :process,
      :roast_level,
      :image,
      :notes
    )
  end
end
