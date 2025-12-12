class CoffeeBeansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_coffee_bean, only: %i[show edit update destroy]
  before_action :set_origins, only: %i[new create edit update]

  def index
    @coffee_beans = CoffeeBean.all
  end

  def show
  end

  def new
    @coffee_bean = CoffeeBean.new
  end

  def create
    @coffee_bean = CoffeeBean.new(coffee_bean_params)

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
    redirect_to coffee_beans_path, notice: "コーヒー豆を更新しました"
  else
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
  end

  private

  def set_coffee_bean
    @coffee_bean = CoffeeBean.find(params[:id])
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
      :images,
      :notes
    )
  end
end
