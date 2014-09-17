module DjMon
  class DjReportsController < ActionController::Base
    respond_to :html
    layout 'dj_mon'

    before_filter :authenticate
    before_filter :dj_counts
    before_filter :get_distinct_queues

    def index
      redirect_to action: 'all'
    end

    def all
      @reports = Delayed::Job.scoped
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => DjMon::PAGE_SIZE)
      render 'index'
    end

    def failed
      @reports = Delayed::Job.where('failed_at IS NOT NULL')
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => DjMon::PAGE_SIZE)
      render 'index'
    end

    def active
      @reports = Delayed::Job.where('failed_at IS NULL AND locked_by IS NOT NULL')
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => DjMon::PAGE_SIZE)
      render 'index'
    end

    def queued
      @reports = Delayed::Job.where('failed_at IS NULL AND locked_by IS NULL')
      @reports = @reports.where(queue: params[:queue]) if params[:queue]
      @reports = @reports.paginate(page: params[:page], :per_page => DjMon::PAGE_SIZE)
      render 'index'
    end

    def queues
      @queues = Delayed::Job.select("queue, COUNT(*) AS count").group("queue")
      respond_with @queues.map{|queue| { queue: "#{queue.queue.present? ? queue.queue.capitalize : 'Blank'}", count: queue.count}}
    end

    def dj_counts
      @counts = {
          all: Delayed::Job.scoped.size,
          failed: Delayed::Job.where('failed_at IS NOT NULL').size,
          active: Delayed::Job.where('failed_at IS NULL AND locked_by IS NOT NULL').size,
          queued: Delayed::Job.where('failed_at IS NULL AND locked_by IS NULL').size
        }
    end

    def get_distinct_queues
      @queue_names = Delayed::Job.select(:queue).map(&:queue).uniq
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

    def edit
      @job = Delayed::Job.find(params[:id])
    end

    def update
      @job = Delayed::Job.find(params[:id])

      if @job.update_attributes(params[:delayed_backend_active_record_job])
        respond_to do |format|
          format.html { redirect_to root_url, :notice => "The job was updated." }
        end
      else
        respond_to do |format|
          format.html { render :edit, :error => "Error updating record." }
        end
      end
    end

    protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Rails.configuration.dj_mon.username &&
        password == Rails.configuration.dj_mon.password
      end
    end
  end

end