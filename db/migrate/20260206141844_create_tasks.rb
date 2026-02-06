class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.integer :priority
      t.boolean :completed, default: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
