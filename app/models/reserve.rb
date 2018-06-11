class Reserve < ApplicationRecord
  belongs_to :collectible

  validates :eth_address, :email, presence: true
end
