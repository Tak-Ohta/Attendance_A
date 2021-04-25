# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210425055009) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.datetime "scheduled_end_time"
    t.boolean "next_day_for_overtime"
    t.string "instructor"
    t.string "work_contents"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approval_check_box", default: false
    t.string "select_superior_for_overtime"
    t.string "confirm_superior_for_overtime"
    t.string "select_superior_for_monthly_attendance"
    t.string "confirm_superior_for_monthly_attendance"
    t.boolean "monthly_attendance_check_box"
    t.string "monthly_attendance_approval_result"
    t.datetime "change_started_at"
    t.datetime "change_finished_at"
    t.datetime "re_change_started_at"
    t.datetime "re_change_finished_at"
    t.string "select_superior_for_attendance_change"
    t.string "confirm_superior_for_attendance_change"
    t.boolean "next_day_for_attendance_change"
    t.boolean "check_box_for_attendance_change"
    t.string "instructor_for_attendances_change"
    t.datetime "attendances_change_approval_day"
    t.string "superior_for_attendance_log"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "base_points", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.string "password_digest"
    t.datetime "basic_work_time", default: "2021-04-24 23:00:00"
    t.datetime "designated_work_start_time", default: "2021-04-25 00:00:00"
    t.datetime "designated_work_end_time", default: "2021-04-25 09:00:00"
    t.boolean "superior"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
