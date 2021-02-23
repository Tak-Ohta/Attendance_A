class AttendancesController < ApplicationController

  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_application, :update_overtime_application]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_overtime_application]
  before_action :superiors, only: [:edit_one_month, :edit_overtime_application]
  before_action :overtime_application, only: [:edit_overtime_application, :update_overtime_application]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  # 出勤中の社員を表示
  def index
    @users = User.all
    
  end
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update(started_at: Time.current.change(sec: 0))
        flash[:success] = "おはようございます。出勤時間を登録しました。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.started_at.present? && @attendance.finished_at.nil?
      if @attendance.update(finished_at: Time.current.change(sec: 0))
        flash[:success] = "お疲れ様でした。退勤時間を登録しました。"
      else
       flash[:danger] = UPDATE_ERROR_MSG  
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_overtime_application
  end

  def update_overtime_application
    overtime_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update(item)
        flash[:success] = "残業申請が完了しました。"
      else
        flash[:danger] = "残業申請に失敗しました。"
      end
      redirect_to @user
    end
  end

  private
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :instructor])[:attendances]
    end

    def overtime_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day, :work_contents, :instructor])[:attendances]
    end

    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "参照・編集権限がありません。"
        redirect_to root_url
      end
    end
  
    def superiors
      @superiors = User.where(superior: true)
    end

    def overtime_application
      @attendance = @user.attendances.find_by(worked_on: params[:date])
    end
end
