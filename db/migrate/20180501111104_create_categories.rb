class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :keyword

      t.string :title
      t.text :description

      t.timestamps
    end
  end
end