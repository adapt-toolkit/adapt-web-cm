json.extract! collectible, :id, :category_id, :hashsum, :ext, :width, :height, :description, :amount, :eth, :created_at, :updated_at
json.url collectible_url(collectible, format: :json)
