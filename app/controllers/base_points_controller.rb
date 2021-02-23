class BasePointsController < ApplicationController
 
  before_action :admin_user, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @base_points = BasePoint.all
  end

  def new
    @base_point = BasePoint.new
  end

  def create
    @base_point = BasePoint.new(base_point_params)
    if @base_point.save
      flash[:success] = "拠点情報を新規登録しました。"
      redirect_to base_points_url
    else
      flash.now[:danger] = "拠点情報の登録に失敗しました。入力漏れがないか確認してください。"
      render :new
    end
  end

  def edit
    @base_point = BasePoint.find(params[:id])
  end

  def update
    @base_point = BasePoint.find(params[:id])
    if @base_point.update(base_point_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to base_points_url
    else
      flash.now[:danger] = "拠点情報の更新に失敗しました。入力漏れがないか確認してください。"
      render :edit
    end
  end

  def destroy
    @base_point = BasePoint.find(params[:id])
    if @base_point.destroy
      flash[:success] = "#{@base_point.base_name}の拠点情報を削除しました。"
    else
      flash.now[:danger] = "#{@base_point.base_name}の削除に失敗しました。やり直してください。"
    end
    redirect_to base_points_url
  end


  private
    def base_point_params
      params.require(:base_point).permit(:base_number, :base_name, :attendance_type)
    end
end
