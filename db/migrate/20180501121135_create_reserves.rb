class CreateReserves < ActiveRecord::Migration[5.1]
  def change
    create_table :reserves do |t|
      t.references :collectible, foreign_key: true, index: true

      t.string :email
      t.boolean :confirmed

      t.timestamps
    end
  end
end
