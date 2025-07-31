# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_05_16_192319) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "computers", force: :cascade do |t|
    t.string "name"
    t.string "ip"
    t.string "port"
    t.string "password"
    t.boolean "selected", default: false
    t.boolean "active", default: true
    t.integer "timezone"
    t.string "domain_name"
    t.string "cpid"
    t.integer "cpu_count"
    t.string "vendor"
    t.string "model"
    t.string "features"
    t.float "fpops"
    t.float "iops"
    t.bigint "membw"
    t.bigint "calculated"
    t.integer "vm_extensions_disabled", default: 0
    t.bigint "nbytes"
    t.bigint "cache"
    t.bigint "swap"
    t.bigint "total_memory"
    t.bigint "free_memory"
    t.string "os_name"
    t.string "os_version"
    t.string "product_name"
    t.string "virtualbox_version"
    t.text "host_info_xml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip"], name: "index_computers_on_ip"
    t.index ["name", "ip"], name: "index_computers_on_name_and_ip", unique: true
    t.index ["name"], name: "index_computers_on_name"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "computer"
    t.string "project"
    t.string "application"
    t.string "name"
    t.string "cpu"
    t.string "progress"
    t.string "elapsed"
    t.string "remaining"
    t.string "deadline"
    t.string "status"
    t.text "result_xml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["computer", "name"], name: "index_tasks_on_computer_and_name", unique: true
    t.index ["computer"], name: "index_tasks_on_computer"
    t.index ["name"], name: "index_tasks_on_name"
    t.index ["status"], name: "index_tasks_on_status"
  end

end
