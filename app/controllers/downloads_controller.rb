class DownloadsController < ApplicationController
  # before_action :set_download, only: [:destroy]

  # GET /downloads
  # GET /downloads.json
  def index
    @downloads = Download.all
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
