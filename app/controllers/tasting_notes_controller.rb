class TastingNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tasting_note, only: %i[show edit update destroy]
  before_action :set_coffee_bean, only: %i[new create edit update destroy]

  def index
    @tasting_notes = current_user.tasting_notes.includes(:coffee_bean, :shop)
  end

  def show
  end

  def new
    @tasting_note = @coffee_bean.tasting_notes.build()
  end

  def create
    @tasting_note = @coffee_bean.tasting_notes.build(tasting_note_params)
    @tasting_note.user = current_user

    if @tasting_note.save
      redirect_to tasting_notes_path, notice: "テイスティングノートを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tasting_note.update(tasting_note_params)
      redirect_to tasting_notes_path, notice: "テイスティングノートを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tasting_note.destroy
    redirect_to tasting_notes_path, notice: "テイスティングノートを削除しました"
  end

  private

  def set_tasting_note
    @tasting_note = current_user.tasting_notes.find(params[:id])
  end

  def set_coffee_bean
    @coffee_bean = current_user.coffee_beans.find(params[:coffee_bean_id])
  end

  def tasting_note_params
    params.require(:tasting_note).permit(
      :coffee_bean_id,
      :shop_id,
      :brew_method,
      :preference_score,
      :acidity_score,
      :bitterness_score,
      :sweetness_score,
      :taste_notes
    )
  end
end
