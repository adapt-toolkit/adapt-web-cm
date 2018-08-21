class CollectiblesController < ApplicationController
  before_action :set_collectible, only: [:show, :edit, :update, :destroy, :sort_order_up, :sort_order_down]
  before_action :preload_options_for_collections, only: [:new, :edit, :create, :update]

  # GET /collectibles
  # GET /collectibles.json
  def index
    @collectibles_grouped = 
      Collectible.select("collectibles.*, COUNT(reserves.id) as reserves_count")
        .joins("LEFT OUTER JOIN reserves ON (reserves.collectible_id = collectibles.id)")
        .group("collectibles.id")
        .order(category_id: :asc, sort_order: :asc, created_at: :asc).all.group_by(&:category)
  end

  # GET /collectibles/1
  # GET /collectibles/1.json
  def show
    @reserves = @collectible.reserves
  end

  # GET /collectibles/new
  def new
    @collectible = Collectible.new
    @categories = Category.all
  end

  # GET /collectibles/1/edit
  def edit
    @categories = Category.all
  end

  # POST /collectibles
  # POST /collectibles.json
  def create
    # CarrierWave attrs->filename hack
    @collectible = Collectible.new(collectible_params.except(:collectible_file, :json_file))
    @collectible.assign_attributes(collectible_params.slice(:collectible_file, :json_file))

    respond_to do |format|
      if @collectible.save
        format.html { redirect_to @collectible, notice: 'Collectible was successfully created.' }
        format.json { render :show, status: :created, location: @collectible }
      else
        format.html { render :new }
        format.json { render json: @collectible.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collectibles/1
  # PATCH/PUT /collectibles/1.json
  def update
    # CarrierWave attrs->filename hack
    @collectible.assign_attributes(collectible_params.except(:collectible_file, :json_file))
    @collectible.assign_attributes(collectible_params.slice(:collectible_file, :json_file))

    respond_to do |format|
      if @collectible.save
        format.html { redirect_to @collectible, notice: 'Collectible was successfully updated.' }
        format.json { render :show, status: :ok, location: @collectible }
      else
        format.html { render :edit }
        format.json { render json: @collectible.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collectibles/1
  # DELETE /collectibles/1.json
  def destroy
    @collectible.destroy
    respond_to do |format|
      format.html { redirect_to collectibles_url, notice: 'Collectible was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sort_order_up
    prev_record = @collectible.prev_record
    if prev_sort_order_value = prev_record.try(:sort_order)
      prev_record.update_column(:sort_order, @collectible.sort_order)
      @collectible.update_column(:sort_order, prev_sort_order_value)
    end
    redirect_to collectibles_url
  end

  def sort_order_down
    next_record = @collectible.next_record
    if next_sort_order_value = next_record.try(:sort_order)
      next_record.update_column(:sort_order, @collectible.sort_order)
      @collectible.update_column(:sort_order, next_sort_order_value)
    end
    redirect_to collectibles_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collectible
      @collectible = Collectible.find(params[:id])
    end

    def preload_options_for_collections
      @categories = Category.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collectible_params
      params.require(:collectible).permit(:category_id, :collectible_file, :collectible_file_name, :json_file, :json_file_name, :description, :amount, :eth, :unsaleable, :sort_order)
    end
end
