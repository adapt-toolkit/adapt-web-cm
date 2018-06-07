class AddUnselableFlagToCollectibles < ActiveRecord::Migration[5.1]
  def change
    add_column :collectibles, :unsaleable, :boolean, default: false, null: false
  end
end
