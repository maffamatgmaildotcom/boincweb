class CreateComputers < ActiveRecord::Migration[7.0]
  def change
    create_table :computers do |t|
      t.string :name
      t.string :ip
      t.string :port
      t.string :password
      t.boolean :selected, default: false
      t.boolean :active, default: true
      t.integer :timezone,  null: true
      t.string :domain_name, null: true
      t.string :cpid, null: true
      t.integer :cpu_count, null: true
      t.string :vendor, null: true
      t.string :model, null: true
      t.string :features, null: true
      t.float :fpops, null: true
      t.float :iops, null: true
      t.bigint :membw, null: true
      t.bigint :calculated, null: true
      t.integer :vm_extensions_disabled, default: 0
      t.bigint :nbytes, null: true
      t.bigint :cache, null: true
      t.bigint :swap, null: true
      t.bigint :total_memory, null: true
      t.bigint :free_memory, null: true
      t.string :os_name, null: true
      t.string :os_version, null: true
      t.string :product_name, null: true
      t.string  :virtualbox_version, null: true

      # Foreign key to the user who owns this computer
      # t.references :user, null: false, foreign_key: true
      #
      t.text :host_info_xml, null: true 
      t.timestamps
    end
    add_index :computers, :name
    add_index :computers, :ip
    add_index :computers, [:name, :ip], unique: true

  end
end
