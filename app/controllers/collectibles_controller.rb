class CollectiblesController < ApplicationController
  before_action :set_collectible, only: [:show, :edit, :update, :destroy]
  before_action :preload_options_for_collections, only: [:new, :edit, :create, :update]

  # GET /collectibles
  # GET /collectibles.json
  def index
    @collectibles = Collectible.all
  end

  # GET /collectibles/1
  # GET /collectibles/1.json
  def show
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
    @collectible = Collectible.new(collectible_params)

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
    respond_to do |format|
      if @collectible.update(collectible_params)
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
      params.require(:collectible).permit(:category_id, :collectible_file, :description, :amount, :eth)
    end
end
