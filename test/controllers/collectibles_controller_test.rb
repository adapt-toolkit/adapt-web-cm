require 'test_helper'

class CollectiblesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @collectible = collectibles(:one)
  end

  test "should get index" do
    get collectibles_url
    assert_response :success
  end

  test "should get new" do
    get new_collectible_url
    assert_response :success
  end

  test "should create collectible" do
    assert_difference('Collectible.count') do
      post collectibles_url, params: { collectible: { amount: @collectible.amount, category_id: @collectible.category_id, description: @collectible.description, eth: @collectible.eth, ext: @collectible.ext, hashsum: @collectible.hashsum, height: @collectible.height, width: @collectible.width } }
    end

    assert_redirected_to collectible_url(Collectible.last)
  end

  test "should show collectible" do
    get collectible_url(@collectible)
    assert_response :success
  end

  test "should get edit" do
    get edit_collectible_url(@collectible)
    assert_response :success
  end

  test "should update collectible" do
    patch collectible_url(@collectible), params: { collectible: { amount: @collectible.amount, category_id: @collectible.category_id, description: @collectible.description, eth: @collectible.eth, ext: @collectible.ext, hashsum: @collectible.hashsum, height: @collectible.height, width: @collectible.width } }
    assert_redirected_to collectible_url(@collectible)
  end

  test "should destroy collectible" do
    assert_difference('Collectible.count', -1) do
      delete collectible_url(@collectible)
    end

    assert_redirected_to collectibles_url
  end
end
