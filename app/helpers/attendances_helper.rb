module AttendancesHelper

  # 在社時間の計算
  def working_time(start, finish)
    format("%.2f", ((finish - start) / 60) / 60.0)
  end

  # 残業時間の計算
  def overtime(scheduled_end_time)
    designated_work_end_time = @user.designated_work_end_time.change(
                              year: day.worked_on.year, month: day.worked_on.month, day: day.worked_on
                              )
    format("%.2f", ((scheduled_end_time - designated_work_end_time) / 60) / 60.0)
  end
end
