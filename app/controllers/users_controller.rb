class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_overtime_application]
  before_action :admin_user, only: [:index, :destroy, :at_work, :edit_basic_info]
  before_action :admin_or_correct_user, only: [:edit, :update]
  before_action :admin_or_correct_user_or_superior, only: :show
  before_action :set_one_month, only: :show
  before_action :superiors, only: :show

  def new
    @user = User.new
  end

  def show
    # 出勤日数
    @worked_sum = @attendances.where.not(started_at: nil).count
    # 所属長承認申請のお知らせ（上長ごとに、1ヶ月分の勤怠申請がされている件数をカウント）
    if current_user.superior?
      @monthly_attendance_application = Attendance.where(select_superior_for_monthly_attendance: current_user.name)
                                                  .where(monthly_attendance_approval_result: [nil, '']).count
    end
    # 勤怠変更申請のお知らせ
    if current_user.superior?
      @attendances_change_application = Attendance.where(select_superior_for_attendance_change: current_user.name)
                                                  .where("instructor_for_attendances_change LIKE ?", "%申請中").count
    end
    
    # 残業申請のお知らせ（上長ごとに、残業申請がされている件数をカウント）
    if current_user.superior?
      @overtime_application = Attendance.where(select_superior_for_overtime: current_user.name).count
    end

    # 申請中を除くcsv出力用データ
    @csv_outputs = @attendances.where.not("instructor_for_attendances_change LIKE ?", "%申請中")
    # csv出力
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendances_csv(@csv_outputs)
      end
    end
  end

  # 勤怠csv出力
  def send_attendances_csv(attendances)
    csv_data = CSV.generate(headers: true) do |csv|
      header = ["日付", "出社時間", "退社時間", "変更後出社時間", "変更後退社時間", "指示者確認 &#12958;"]
      # 表のカラム名を定義
      csv << header
      # column_valuesに代入するカラム値を定義
      attendances.each do |attendance|
        values = [attendance.worked_on,
          attendance.change_before_started_at.present? ? attendance.change_before_started_at.floor_to(15.minutes).strftime("%H:%M") : nil,
          attendance.change_before_finished_at.present? ? attendance.change_before_finished_at.floor_to(15.minutes).strftime("%H:%M") : nil,
          attendance.started_at.present? ? attendance.started_at.floor_to(15.minutes).strftime("%H:%M") : nil,
          attendance.finished_at.present? ? attendance.finished_at.floor_to(15.minutes).strftime("%H:%M") : nil,
          attendance.instructor_for_attendances_change
          ]
        # 表の値を定義
        csv << values
      end
    end
    send_data(csv_data, filename: "勤怠情報-#{User.find(params[:id]).name}-#{Time.zone.now.strftime('%Y%m%d%S')}.csv")
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
    flash[:success] = "ユーザーを追加しました。"
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to user_url(current_user)
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

  # 出勤社員一覧
  def at_work
    @users = User.all.includes(:attendances).where(attendances: { worked_on: Date.current })
                                            .where.not(attendances: { started_at: nil })
                                            .where(attendances: { finished_at: nil })
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