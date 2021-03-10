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

ActiveRecord::Schema.define(version: 20181226135004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.string   "status"
    t.integer  "is_new_customer"
    t.datetime "schedule_time"
    t.text     "comments"
    t.integer  "seller_id"
    t.integer  "customer_id"
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "postal_code"
    t.integer  "windows_num"
    t.integer  "doors_num"
    t.string   "how_soon"
    t.string   "quotes_num"
    t.string   "hear_about_us"
    t.string   "homeoweners_at_home"
    t.string   "supply_install"
    t.string   "financing"
    t.integer  "installer_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.datetime "end_time"
    t.datetime "followup_time"
    t.integer  "sealed"
    t.string   "booking_by"
    t.string   "app_type"
    t.string   "cancel_reason"
    t.string   "followup_timeframe"
    t.string   "followup_comments"
    t.datetime "reschedule_time"
    t.string   "reschedule_reason"
    t.string   "sold_snap"
    t.decimal  "sold_amount",                 precision: 8, scale: 2
    t.decimal  "sold_energy_charge",          precision: 8, scale: 2
    t.decimal  "sold_gst",                    precision: 8, scale: 2
    t.decimal  "sold_credit_card",            precision: 8, scale: 2
    t.decimal  "sold_total",                  precision: 8, scale: 2
    t.datetime "sold_due_on_delivery"
    t.decimal  "sold_extra",                  precision: 8, scale: 2
    t.decimal  "sold_discount",               precision: 8, scale: 2
    t.decimal  "sold_amount_of_total",        precision: 8, scale: 2
    t.datetime "sold_delivery_dead_line"
    t.string   "sold_window_series"
    t.integer  "sold_number_of_windows"
    t.integer  "sold_number_of_patio_doors"
    t.integer  "sold_number_of_entry_doors"
    t.integer  "sold_number_of_sealed_units"
    t.string   "sold_grills"
    t.string   "sold_grills_type"
    t.string   "sold_privacy_glass"
    t.string   "sold_privacy_glass_type"
    t.string   "sold_measure_window"
    t.string   "sold_window_color_outside"
    t.string   "sold_window_color_inside"
    t.string   "sold_by"
    t.string   "payment_type"
    t.index ["followup_time"], name: "index_appointments_on_followup_time", using: :btree
    t.index ["installer_id"], name: "index_appointments_on_installer_id", using: :btree
    t.index ["schedule_time"], name: "index_appointments_on_schedule_time", using: :btree
    t.index ["seller_id"], name: "index_appointments_on_seller_id", using: :btree
    t.index ["status"], name: "index_appointments_on_status", using: :btree
  end

  create_table "articles", force: :cascade do |t|
    t.string   "name"
    t.string   "author"
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "file_url"
    t.integer  "appointment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "file_name"
    t.index ["appointment_id"], name: "index_attachments_on_appointment_id", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "customers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "status"
    t.string   "phone"
    t.string   "email"
    t.string   "home_phone"
  end

  create_table "installer_schedules", force: :cascade do |t|
    t.datetime "schedule_time"
    t.integer  "installer_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["installer_id"], name: "index_installer_schedules_on_installer_id", using: :btree
    t.index ["schedule_time"], name: "index_installer_schedules_on_schedule_time", using: :btree
  end

  create_table "seller_schedules", force: :cascade do |t|
    t.datetime "schedule_time"
    t.integer  "seller_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["schedule_time"], name: "index_seller_schedules_on_schedule_time", using: :btree
    t.index ["seller_id"], name: "index_seller_schedules_on_seller_id", using: :btree
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "name"
    t.string   "color"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "role"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.index ["role"], name: "index_users_on_role", using: :btree
    t.index ["status"], name: "index_users_on_status", using: :btree
  end

end
