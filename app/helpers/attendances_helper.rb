module AttendancesHelper

  # 在社時間の計算
  def working_time(start, finish)
    format("%.2f", ((finish - start) / 60) / 60.0)
  end

  # 残業時間計算の日時補正
  def date_correction(worked_on, date)
    date.change(year: worked_on.year, month: worked_on.month, day: worked_on.day)
  end

  # 残業時間の計算
  def overtime(designated_work_end_time, scheduled_end_time)
    format("%.2f", ((scheduled_end_time - designated_work_end_time) / 60) / 60.0)
  end
end
