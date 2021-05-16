class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50}
  validate :change_before_finished_at_is_invalid_without_change_before_started_at
  validate :change_before_finished_at_earlier_than_change_before_started_at_is_invalid
  validate :only_started_at_is_invalid
  validate :only_finished_at_is_invalid
  validate :finished_at_earlier_than_started_at_is_invalid
  validate :only_select_instructor_is_invalid

  # 出勤時間の登録がない退勤時間の登録は無効
  def change_before_finished_at_is_invalid_without_change_before_started_at
    errors.add(:change_before_started_at, "が必要です。") if change_before_started_at.blank? && change_before_finished_at.present?
  end

  # 出勤時間より早い退勤時間の登録は無効
  def change_before_finished_at_earlier_than_change_before_started_at_is_invalid
    if change_before_started_at.present? && change_before_finished_at.present?
      errors.add(:change_before_started_at, "より早い退社時間は無効です。") if change_before_started_at > change_before_finished_at
    end
  end

  # 変更後出勤時間のみの登録は無効
  def only_started_at_is_invalid
    if select_superior_for_attendance_change.present? && started_at.present? && finished_at.blank?
      errors.add(:finished_at, "退社時間が必要です。")
    end
  end

  # 変更後退勤時間のみの登録は無効
  def only_finished_at_is_invalid
    if select_superior_for_attendance_change.present? && finished_at.present? && started_at.blank?
      errors.add(:started_at, "出社時間が必要です。")
    end
  end

  # 出勤時間より早い退勤時間の登録は無効
  def finished_at_earlier_than_started_at_is_invalid
    if started_at.present? && finished_at.present? && select_superior_for_attendance_change.present?
      if next_day_for_attendance_change == true
        errors.add(:started_at, "より早い退社時間は無効です。") if started_at.to_time > finished_at.to_time.tomorrow
      else
        errors.add(:started_at, "より早い退社時間は無効です。") if started_at > finished_at
      end
    end
  end

  # 勤怠変更申請で指示者のみ選択されていて、変更時間がない場合は無効
  def only_select_instructor_is_invalid
    if started_at.blank? && finished_at.blank? && select_superior_for_attendance_change.present?
      errors.add(:started_at, "が必要です。")
    end
  end
end
