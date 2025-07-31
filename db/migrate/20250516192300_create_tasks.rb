class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :computer
      t.string :project
      t.string :application
      t.string :name
      t.string :cpu
      t.string :progress
      t.string :elapsed
      t.string :remaining
      t.string :deadline
      t.string :status
      t.text   :result_xml

      t.timestamps
    end
    add_index :tasks, :name
    add_index :tasks, :computer
    add_index :tasks, :status
    add_index :tasks, [:computer, :name], unique: true
  end
end
