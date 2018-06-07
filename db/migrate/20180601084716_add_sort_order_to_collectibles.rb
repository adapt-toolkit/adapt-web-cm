class AddSortOrderToCollectibles < ActiveRecord::Migration[5.1]
  def change
    add_column :collectibles, :sort_order, :integer, default: 0, null: false
  end
end
