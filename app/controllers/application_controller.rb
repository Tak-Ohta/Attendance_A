class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  $days_of_the_week = %w{日 月 火 水 木 金 土}

  def set_user
    @user = User.find(params[:id])
  end

  # ログインユーザー
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to root_url
    end
  end

  # 管理者ユーザーのみ
  def admin_user
    unless current_user.admin?
      flash[:danger] = "参照・編集権限がありません。"
      redirect_to root_url
    end
  end

  # ログインユーザーまたは管理者
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "参照・編集権限がありません。"
      redirect_to users_url
    end
  end

  # 管理者は勤怠画面の表示と編集は不可
  def admin_impossible
    if current_user.admin?
      flash[:danger] = "管理者は勤怠画面の表示および編集はできません。"
      redirect_to users_url
    end
  end

  # ログインユーザーとログイン先が一致しているか？
  def correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user)
      if current_user.superior?
        if params[:date].present?
          first_day = params[:date].to_date
          attendances = @user.attendances.where(worked_on: first_day..first_day.end_of_month)
          if attendances.pluck(:select_superior_for_attendance_change).include?("#{current_user.name}")
          elsif attendances.pluck(:select_superior_for_overtime).include?("#{current_user.name}")
          elsif attendances.pluck(:select_superior_for_monthly_attendance).include?("#{current_user.name}")
          else
            flash[:danger] = "参照・編集権限がありません。"
            redirect_to root_url
          end
        else
          flash[:danger] = "参照・編集権限がありません。"
          redirect_to root_url
        end
      else
        flash[:danger] = "参照・編集権限がありません。"
        redirect_to root_url
      end
    end
  end

  # ログインユーザーか上長か？
  def correct_user_or_superior
    @user = User.find(params[:id]) if @user.blank?
    unless current_user?(@user) || current_user.superior?
      flash[:danger] = "参照・編集権限がありません。"
      redirect_to root_url
    end
  end

  def superior_user
    redirect_to root_url unless current_user.superior?
  end

  def superiors
    @superiors = User.where(superior: true).where.not(name: @user.name)
  end

  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]

    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)

    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました。再アクセスしてください。"
    redirect_to @user
  end
end
