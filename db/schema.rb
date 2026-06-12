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

ActiveRecord::Schema[8.1].define(version: 2026_06_11_204058) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "computers", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "cache"
    t.bigint "calculated"
    t.string "cpid"
    t.integer "cpu_count"
    t.datetime "created_at", null: false
    t.string "domain_name"
    t.string "features"
    t.float "fpops"
    t.bigint "free_memory"
    t.text "host_info_xml"
    t.float "iops"
    t.string "ip"
    t.bigint "membw"
    t.string "model"
    t.string "name"
    t.bigint "nbytes"
    t.string "os_name"
    t.string "os_version"
    t.string "password"
    t.string "port"
    t.string "product_name"
    t.boolean "selected", default: false
    t.bigint "swap"
    t.integer "timezone"
    t.bigint "total_memory"
    t.datetime "updated_at", null: false
    t.string "vendor"
    t.string "virtualbox_version"
    t.integer "vm_extensions_disabled", default: 0
    t.index ["ip"], name: "index_computers_on_ip"
    t.index ["name", "ip"], name: "index_computers_on_name_and_ip", unique: true
    t.index ["name"], name: "index_computers_on_name"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "application"
    t.string "computer"
    t.string "cpu"
    t.datetime "created_at", null: false
    t.string "deadline"
    t.string "elapsed"
    t.string "name"
    t.string "progress"
    t.string "project"
    t.string "remaining"
    t.text "result_xml"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["computer", "name"], name: "index_tasks_on_computer_and_name", unique: true
    t.index ["computer"], name: "index_tasks_on_computer"
    t.index ["name"], name: "index_tasks_on_name"
    t.index ["status"], name: "index_tasks_on_status"
  end
end
