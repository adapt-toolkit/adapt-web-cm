class AddEthAddressToReserves < ActiveRecord::Migration[5.1]
  def change
    add_column :reserves, :eth_address, :string
  end
end
