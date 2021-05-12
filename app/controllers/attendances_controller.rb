class AttendancesController < ApplicationController

  before_action :set_user, only: [:edit_attendances_change_application, :update_attendances_change_application,
                                  :update_monthly_attendance_application,
                                  :edit_overtime_application, :update_overtime_application, :attendance_log]
  before_action :logged_in_user, only: [:update, :edit_attendances_change_application, :update_attendances_change_application,
                                  :edit_overtime_application, :update_overtime_application, :attendance_log]
  before_action :admin_user, only: :index
  before_action :correct_user, only: [:update, :edit_attendances_change_application, :update_attendances_change_application,
                                  :update_monthly_attendance_application, :edit_overtime_application, :update_overtime_application, :attendance_log]
  before_action :superior_user, only: [:edit_overtime_approval, :update_overtime_approval, :edit_monthly_attendance_approval, :update_monthly_attendance_approval,
                                      :edit_attendances_change_approval, :update_attendances_change_approval]
  before_action :set_one_month, only: [:edit_attendances_change_application, :edit_overtime_application, :attendance_log]
  before_action :superiors, only: [:edit_attendances_change_application, :edit_overtime_application]
  before_action :overtime_application, only: [:edit_overtime_application, :update_overtime_application]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  # 出勤中の社員を表示
  def index
    @users = User.all
    
  end
  
  # 出退勤打刻
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update(started_at: Time.current.change(sec: 0)) && @attendance.update(change_before_started_at: Time.current.change(sec: 0))
        flash[:success] = "おはようございます。出勤時間を登録しました。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.started_at.present? && @attendance.finished_at.nil?
      if @attendance.update(finished_at: Time.current.change(sec: 0)) && @attendance.update(change_before_finished_at: Time.current.change(sec: 0))
        flash[:success] = "お疲れ様でした。退勤時間を登録しました。"
      else
       flash[:danger] = UPDATE_ERROR_MSG  
      end
    end
    redirect_to @user
  end

  # 1ヶ月の勤怠承認申請
  def edit_monthly_attendance_application
  end

  def update_monthly_attendance_application
    monthly_attendance_application_params.each do |id, item|
      attendance = Attendance.find(id)
      attendance.monthly_attendance_approval_result = nil
      if monthly_attendance_application_params[id][:select_superior_for_monthly_attendance].present?
        if attendance.update(item)
          flash[:success] = "#{attendance.select_superior_for_monthly_attendance}へ1ヶ月分の勤怠を申請しました。"
        else
          flash[:danger] = "1ヶ月分の勤怠申請に失敗しました。"
        end
      else
        flash[:danger] = "所属長を選択してください。"
      end
      redirect_to user_url(@user, date: attendance.worked_on.beginning_of_month)
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

  # 勤怠変更申請
  def edit_attendances_change_application
  end

  def update_attendances_change_application
    ActiveRecord::Base.transaction do
      attendances_change_application_params.each do |id, item|
        attendance = Attendance.find(id)
        if attendances_change_application_params[id][:select_superior_for_attendance_change].blank?
        else
          if attendances_change_application_params[id][:started_at].present? && attendances_change_application_params[id][:finished_at].present?
            if attendance.change_before_started_at.blank?
              attendance.change_before_started_at = attendances_change_application_params[id][:started_at]
            end
            if attendance.change_before_finished_at.blank?
              if attendances_change_application_params[id][:next_day_for_attendance_change] == "true"
                attendance.change_before_finished_at = attendances_change_application_params[id][:finished_at].to_time.tomorrow
              else
                attendance.change_before_finished_at = attendances_change_application_params[id][:finished_at]
              end
            end
          end
          attendance.confirm_superior_for_attendance_change = nil
          attendance.instructor_for_attendances_change = "#{attendances_change_application_params[id][:select_superior_for_attendance_change]}へ勤怠変更申請中"
          attendance.instructor_of_attendances_log = attendances_change_application_params[id][:select_superior_for_attendance_change]
          attendance.update!(item)
          flash[:success] = "勤怠の変更申請を送信しました。"
        end
      end
    end
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあったため、更新をキャンセルしました。"
    redirect_to attendances_edit_attendances_change_application_user_url(date: params[:date])
  end

  # 勤怠変更申請承認
  def edit_attendances_change_approval
    @users = User.includes(:attendances).where(attendances: { select_superior_for_attendance_change: current_user.name })
                                        .where("instructor_for_attendances_change LIKE ?", "%申請中").order("attendances.worked_on")
  end

  def update_attendances_change_approval
    ActiveRecord::Base.transaction do
      attendances_change_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        user = User.find(attendance.user_id)
        if attendances_change_approval_params[id][:check_box_for_attendance_change] == "true"
          if attendances_change_approval_params[id][:confirm_superior_for_attendance_change] == "承認"
            attendance.instructor_for_attendances_change = "勤怠変更承認済"
            attendances_change_application_params[id][:select_superior_for_attendance_change] = nil
          elsif attendances_change_approval_params[id][:confirm_superior_for_attendance_change] == "否認"
            attendance.instructor_for_attendances_change = "勤怠変更否認"
            attendances_change_application_params[id][:select_superior_for_attendance_change] = nil
          elsif attendances_change_approval_params[id][:confirm_superior_for_attendance_change] == "申請中"
            attendance.instructor_for_attendances_change = "勤怠変更申請中"
          elsif attendances_change_approval_params[id][:confirm_superior_for_attendance_change] == "なし"
            attendance.instructor_for_attendances_change = "勤怠変更なし"
            attendances_change_approval_params[id][:started_at] = nil
            attendances_change_approval_params[id][:finished_at] = nil
            attendances_change_approval_params[id][:next_day_for_attendance_change] = nil
            attendances_change_approval_params[id][:note] = nil
            attendances_change_approval_params[:select_superior_for_attendance_change] = nil
          end
          attendance.attendances_change_approval_day = Date.current
          if attendance.update!(item)
            flash[:success] = "勤怠変更申請の結果を送信しました。"
          end
        end
      end
    end
    redirect_to user_url(current_user)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "勤怠変更申請の送信に失敗しました。"
    redirect_to user_url(current_user)
  end


  # 残業申請
  def edit_overtime_application
    @attendance = @user.attendances.find_by(worked_on: params[:date])
  end

  def update_overtime_application
    overtime_application_params.each do |id, item|
      attendance = Attendance.find(id)
      
      if overtime_application_params[id][:scheduled_end_time].blank? || overtime_application_params[id][:work_contents].blank? || overtime_application_params[id][:select_superior_for_overtime].blank?
        flash[:danger] = "終了予定時間、業務内容、または、指示者確認欄がありません。"
      else
        attendance.instructor = "#{overtime_application_params[id][:select_superior_for_overtime]}へ残業申請中"
        if attendance.update(item)
          flash[:success] = "#{attendance.select_superior_for_overtime}への残業申請が完了しました。"
        else
          flash[:danger] = "残業申請に失敗しました。無効な入力、もしくは、未入力がないか確認してください。"
        end
      end
      redirect_to user_url(@user, date: attendance.worked_on.beginning_of_month)
    end
  end

  # 残業承認
  def edit_overtime_approval
    @users = User.includes(:attendances).where(attendances: { select_superior_for_overtime: current_user.name })
              .order("attendances.worked_on")
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
          attendance.scheduled_end_time = nil
          attendance.next_day_for_overtime = nil
          attendance.work_contents = nil
          attendance.instructor = "残業なし"
          attendance.select_superior_for_overtime = nil
        else overtime_approval_params[id][:confirm_superior_for_overtime] == "申請中"
          attendance.instructor = "残業申請中"
        end
        if attendance.update(item)
          flash[:success] = "#{user.name}の#{l(attendance.worked_on, format: :short)}分の残業申請を「承認」しました。" if attendance.confirm_superior_for_overtime == "承認"
          flash[:danger] = "#{user.name}の#{l(attendance.worked_on, format: :short)}分の残業申請を「否認」しました。" if attendance.confirm_superior_for_overtime == "否認"
          flash[:danger] = "#{user.name}の#{l(attendance.worked_on, format: :short)}分の残業申請を「なし」にしました。" if attendance.confirm_superior_for_overtime == "なし"
          flash[:danger] = "#{user.name}の#{l(attendance.worked_on, format: :short)}分の残業申請を「申請中」にしました。" if attendance.confirm_superior_for_overtime == "申請中"
        end
      end
    end
      redirect_to user_url(current_user)
  end

  # 勤怠ログ
  def attendance_log
    if params[:attendance].present?
      @search_result = params[:attendance]
      date = Date.new @search_result["worked_on(1i)"].to_i, @search_result["worked_on(2i)"].to_i, @search_result["worked_on(3i)"].to_i
      search_date = date.strftime('%Y-%m')

      @attendances = @user.attendances.where(attendances: { confirm_superior_for_attendance_change: "承認" })
                                      .where( "worked_on LIKE ?", "#{search_date}%" )
    end
  end

  private
    def monthly_attendance_application_params
      params.require(:user).permit(attendance: :select_superior_for_monthly_attendance)[:attendance]
    end

    def monthly_attendance_approval_params
      params.require(:user).permit(attendances: [:confirm_superior_for_monthly_attendance, :monthly_attendance_check_box])[:attendances]
    end

    def attendances_change_application_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day_for_attendance_change, :note, :select_superior_for_attendance_change])[:attendances]
    end

    def attendances_change_approval_params
      params.require(:user).permit(attendances: [:confirm_superior_for_attendance_change, :check_box_for_attendance_change])[:attendances]
    end

    def overtime_application_params
      params.require(:user).permit(attendances: [:scheduled_end_time, :next_day_for_overtime, :work_contents, :instructor, :select_superior_for_overtime])[:attendances]
    end

    def overtime_approval_params
      params.require(:user).permit(attendances: [:user_id, :confirm_superior_for_overtime, :approval_check_box])[:attendances]
    end

    def overtime_application
      @attendance = @user.attendances.find_by(worked_on: params[:date])
    end

end
