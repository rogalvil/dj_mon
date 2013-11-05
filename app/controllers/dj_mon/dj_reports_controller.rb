module DjMon
  class DjReportsController < ActionController::Base
    respond_to :json, :html
    layout 'dj_mon'

    before_filter :authenticate
    before_filter :set_api_version

    def index
      @reports = DjReport.all_reports.paginate(page: params[:page], :per_page => 5)
      respond_with @reports
    end

    def all
      @reports = DjReport.all_reports.paginate(page: params[:page], :per_page => 5)
      respond_with @reports
    end

    def failed
      @reports = DjReport.failed_reports.paginate(page: params[:page], :per_page => 5)
      respond_with @reports
    end

    def active
      @reports = DjReport.active_reports.paginate(page: params[:page], :per_page => 5)
      respond_with @reports
    end

    def queued
      @reports = DjReport.queued_reports.paginate(page: params[:page], :per_page => 5)
      respond_with @reports
    end

    def dj_counts
      respond_with DjReport.dj_counts
    end

    def settings
      respond_with DjReport.settings
    end

    def retry
      DjMon::Backend.retry params[:id]
      respond_to do |format|
        format.html { redirect_to root_url, :notice => "The job has been queued for a re-run" }
        format.json { head(:ok) }
      end
    end

    def destroy
      DjMon::Backend.destroy params[:id]
      respond_to do |format|
        format.html { redirect_to root_url, :notice => "The job was deleted" }
        format.json { head(:ok) }
      end
    end

    protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.configuration.dj_mon.username &&
        password == Rails.configuration.dj_mon.password
      end
    end

    def set_api_version
      response.headers['DJ-Mon-Version'] = DjMon::VERSION
    end

  end

end
