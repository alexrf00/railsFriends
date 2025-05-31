class CreateFriends < ActiveRecord::Migration[8.0]
  def change
    create_table :friends do |t|
      t.string :name
      t.string :email
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
