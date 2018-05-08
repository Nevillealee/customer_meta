class CreateMetas < ActiveRecord::Migration[5.2]
  def change
    create_table :metas do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :customer_string
      t.timestamps
    end
  end
end
