class CreateCollectibles < ActiveRecord::Migration[5.1]
  def change
    create_table :collectibles do |t|
      t.references :category, foreign_key: true, index: true

      t.string :collectible_file

      t.string :hashsum
      t.string :ext

      t.integer :width
      t.integer :height

      t.text :description

      t.integer :amount
      t.float :eth

      t.timestamps
    end
  end
end
