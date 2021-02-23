class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50}
  validate :finished_at_is_invalid_without_started_at
  validate :finished_at_earlier_than_started_at_is_invalid

  def finished_at_is_invalid_without_started_at
    errors.add(:started_at, "が必要です。") if started_at.blank? && finished_at.present?
  end

  def finished_at_earlier_than_started_at_is_invalid
    if started_at.present? && finished_at.present?
      errors.add("started_at", "より早い退社時間は無効です。") if started_at > finished_at
    end
  end
end
