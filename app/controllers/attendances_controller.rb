class AttendancesController < ApplicationController

  before_action :set_user, only: [:edit_attendances_change_application, :update_attendances_change_application,
                                  :update_monthly_attendance_application,
                                  :edit_overtime_application, :update_overtime_application]
  before_action :logged_in_user, only: [:update, :edit_attendances_change_application, :update_attendances_change_application,
                                  :edit_overtime_application, :update_overtime_application]
  before_action :admin_or_correct_user, only: [:update, :edit_attendances_change_application, :update_attendances_change_application,
                                  :update_monthly_attendance_application,
                                  :edit_overtime_application, :update_overtime_application]
  before_action :superior_user, only: [:edit_overtime_approval, :update_overtime_approval]
  before_action :set_one_month, only: [:edit_attendances_change_application, :edit_overtime_application]
  before_action :superiors, only: [:edit_attendances_change_application, :edit_overtime_application]
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

  # 個々の勤怠変更申請
  def edit_attendances_change_application
  end
  # 修正中：申請後、申請者の指示者確認印に「勤怠変更申請中」と表示するようにする！
  def update_attendances_change_application
    
    ActiveRecord::Base.transaction do
      attendances_change_params.each do |id, item|
        attendance = Attendance.find(id)
        unless attendances_change_params[id][:select_superior_for_attendance_change].nil?
          attendance.instructor_for_attendances_change = "#{attendances_change_params[id][:select_superior_for_attendance_change]}へ勤怠変更申請中"
        end
        attendance.update!(item)
      end
    end
    flash[:success] = "勤怠の変更申請を送信しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # 1ヶ月の勤怠承認申請
  def edit_monthly_attendance_application
  end

  def update_monthly_attendance_application
    monthly_attendance_application_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.monthly_attendance_approval_result = nil
      if attendance.update(item)
        flash[:success] = "#{attendance.select_superior_for_monthly_attendance}へ1ヶ月分の勤怠を申請しました。"
      else
        flash[:danger] = "1ヶ月分の勤怠申請に失敗しました。"
      end
      redirect_to @user
    end
  end

  # 1ヶ月の勤怠承認
  def edit_monthly_attendance_approval
    @users = User.includes(:attendances).where(attendances: {select_superior_for_monthly_attendance: current_user.name}).
                                        where(attendances: {monthly_attendance_approval_result: [nil, '']})
  end

  def update_monthly_attendance_approval
    monthly_attendance_approval_params.each do |id, item|
      attendance = Attendance.find(id)
      user = User.find(attendance.user_id)
      if monthly_attendance_approval_params[id][:monthly_attendance_check_box] == "true"
        if monthly_attendance_approval_params[id][:confirm_superior_for_monthly_attendance] == "承認"
          attendance.monthly_attendance_approval_result = "#{attendance.select_superior_for_monthly_attendance}から承認済"
        elsif monthly_attendance_approval_params[id][:confirm_superior_for_monthly_attendance] == "否認"
          attendance.monthly_attendance_approval_result = "#{attendance.select_superior_for_monthly_attendance}から否認"
        elsif monthly_attendance_approval_params[id][:confirm_superior_for_monthly_attendance] == "なし"
          attendance.monthly_attendance_approval_result = "#{attendance.select_superior_for_monthly_attendance}からなし"
        else monthly_attendance_approval_params[id][:confirm_superior_for_monthly_attendance] == "申請中"
          attendance.monthly_attendance_approval_result = "#{attendance.select_superior_for_monthly_attendance}から保留"
        end
        if attendance.update(item)
          flash[:success] = "変更を送信しました。"
        else
          flash[:danger] = "変更を送信できませんでした。"
        end
      else
        flash[:danger] = "#{user.name}の「変更」欄にチェックがありません。"
      end
    end
    redirect_to user_url(current_user)
  end

  # 残業申請
  def edit_overtime_application
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end

  def update_overtime_application
    overtime_application_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.instructor = "#{overtime_application_params[id][:select_superior_for_overtime]}へ残業申請中"
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

  private
    def attendances_change_params
      params.require(:user).permit(attendances: [:re_change_started_at, :re_change_finished_at, :next_day_for_attendance_change, :note, :select_superior_for_attendance_change])[:attendances]
    end

    def monthly_attendance_application_params
      params.require(:user).permit(attendance: :select_superior_for_monthly_attendance)[:attendance]
    end

    def monthly_attendance_approval_params
      params.require(:user).permit(attendances: [:confirm_superior_for_monthly_attendance, :monthly_attendance_check_box])[:attendances]
    end

    def overtime_application_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day_for_overtime, :work_contents, :instructor, :select_superior_for_overtime])[:attendances]
    end

    def overtime_approval_params
      params.require(:user).permit(attendances: [:user_id, :confirm_superior_for_overtime, :approval_check_box])[:attendances]
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
