class AttendancesController < ApplicationController

  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_overtime_application, :update_overtime_application]
  before_action :logged_in_user, only: [:update, :edit_one_month, :update_one_month, :edit_overtime_application, :update_overtime_application]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :edit_overtime_application, :update_overtime_application]
  before_action :superior_user, only: [:edit_overtime_approval, :update_overtime_approval]
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

  # 残業申請
  def edit_overtime_application
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end

  def update_overtime_application
    overtime_application_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.instructor = "#{attendance.select_superior_for_overtime}へ残業申請中"
      if attendance.update(item)
        flash[:success] = "残業申請が完了しました。"
      else
        flash[:danger] = "残業申請に失敗しました。無効な入力、もしくは、未入力がないか確認してください。"
      end
      redirect_to @user
    end
  end

  # 残業承認
  def edit_overtime_approval
    @users = User.includes(:attendances).where(attendances: { select_superior_for_overtime: current_user.name })
  end

  def update_overtime_approval
    overtime_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      user = User.find(attendance.user_id)
      if overtime_approval_params[id][:approval_check_box] == "true"
        if overtime_approval_params[id][:confirm_superior_for_overtime] == "承認"
          attendance.instructor = "残業承認済"
          attendance.select_superior_for_overtime = nil
        elsif overtime_approval_params[id][:confirm_superior_for_overtime] == "否認"
          attendance.instructor = "残業否認"
          attendance.select_superior_for_overtime = nil
        elsif overtime_approval_params[id][:confirm_superior_for_overtime] == "なし"
          attendance.instructor = "残業なし"
          attendance.select_superior_for_overtime = nil
        else overtime_approval_params[id][:confirm_superior_for_overtime] == "申請中"
          attendance.instructor = "残業申請中"
        end
        if attendance.update(item)
          flash[:success] = "#{user.name}の残業申請の変更を送信しました。"
        end
      else
        flash[:danger] = "「変更」欄にチェックがありません。#{user.name}の変更を反映できませんでした。"
      end
    end
      redirect_to user_url(current_user)
  end

  # 1ヶ月の勤怠申請
  def edit_monthly_attendance_application
  end

  def update_monthly_attendance_application
    @user = User.find(params[:id])
    
    monthly_attendance_application_params.each do |id, item|
      attendance = Attendance.find(id)
      if attendance.update(item)
        flash[:success] = "#{attendance.select_superior_for_monthly_attendance}へ申請しました。"
      else
        flash[:danger] = "申請に失敗しました。"
      end
      redirect_to @user
    end
  end

  # 1ヶ月の勤怠承認
  def edit_monthly_attendance_approval
  end

  def update_monthly_attendance_approval
  end

  private
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :instructor])[:attendances]
    end

    def overtime_application_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day, :work_contents, :instructor, :select_superior_for_overtime])[:attendances]
    end

    def overtime_approval_params
      params.require(:user).permit(attendances: [:user_id, :confirm_superior_for_overtime, :approval_check_box])[:attendances]
    end

    def monthly_attendance_application_params
      params.require(:user).permit(attendance: :select_superior_for_monthly_attendance)[:attendance]
    end

    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "参照・編集権限がありません。"
        redirect_to root_url
      end
    end

    def overtime_application
      @attendance = @user.attendances.find_by(worked_on: params[:date])
    end
end
