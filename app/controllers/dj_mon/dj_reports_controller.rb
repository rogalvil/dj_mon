module DjMon
  class DjReportsController < ActionController::Base
    respond_to :html
    layout 'dj_mon'

    before_filter :authenticate
    before_filter :set_api_version
    before_filter :dj_counts

    def index
    end

    def all
      @reports = Delayed::Job.scoped
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => 10)
      render 'index'
    end

    def failed
      @reports = Delayed::Job.where('failed_at IS NOT NULL').paginate(page: params[:page], :per_page => 10)
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => 10)
      render 'index'
    end

    def active
      @reports = Delayed::Job.where('failed_at IS NULL AND locked_by IS NOT NULL')
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => 10)
      render 'index'
    end

    def queued
      @reports = Delayed::Job.where('failed_at IS NULL AND locked_by IS NULL')
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => 10)
      render 'index'
    end

    def queues
      @queues = DjMon::Backend.limited.all.select("queue, COUNT(*) AS count").group("queue")
      respond_with @queues.map{|queue| { queue: "#{queue.queue.present? ? queue.queue.capitalize : 'Blank'}", count: queue.count}}
    end

    def dj_counts
      @counts = DjReport.dj_counts
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
