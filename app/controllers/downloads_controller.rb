class DownloadsController < ApplicationController
  # before_action :set_download, only: [:destroy]

  # GET /downloads
  # GET /downloads.json
  def index
    @downloads = Download.all
    @last_24h = Download.where("created_at >= ?", Time.now - 24.hours).count
    @last_7d = Download.where("created_at >= ?", Time.now - 7.days).count
    @last_30d = Download.where("created_at >= ?", Time.now - 30.days).count
    @total = Download.count
  end

  # DELETE /downloads/1
  # DELETE /downloads/1.json
  # def destroy
  #   @download.destroy
  #   respond_to do |format|
  #     format.html { redirect_to downloads_url, notice: 'Download was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_download
    #   @download = Download.find(params[:id])
    # end
end
