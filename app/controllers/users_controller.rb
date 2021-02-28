class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_overtime_application]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy]
  before_action :set_one_month, only: :show

  def new
    @user = User.new
  end

  def show
    # 出勤日数
    @worked_sum = @attendances.where.not(started_at: nil).count
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザー情報を新規登録しました。"
      redirect_to @user
    else
      flash[:danger] = "ユーザー登録に失敗しました。やり直してください。"
      render :new
    end
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def import
    User.import(params[:file])
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      flash[:danger] = "ユーザー情報を更新できませんでした。"
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def at_work
    @users = User.all.includes(:attendances)
    
  end

  def edit_basic_info
  end

  def update_basic_info
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                  :password, :password_confirmation, :basic_work_time,
                                  :designated_work_start_time, :designated_work_end_time)
    end
end