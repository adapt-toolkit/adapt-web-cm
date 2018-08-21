class AddJsonFileToCollectibles < ActiveRecord::Migration[5.1]
  def change
    add_column :collectibles, :json_file, :string
  end
end
