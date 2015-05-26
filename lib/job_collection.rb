require_relative './job'

class JobCollection
  def total
    @jobs.size
  end
  
  def running
    @jobs.select {|j| j.running? }.size
  end
  
  def running?
    0 < running
  end
  
  def start_job(uid = nil)
    @jobs << Job.new(@options, uid: uid)
  end
  
  def existing_job_ids
    WorkingArea.existing_job_ids(@options.working_directory)
  end
  
  def restart_jobs
    existing_job_ids.each do |job_id|
      start_job(job_id)
    end
  end
  
  def initialize(options)
    @options = options
    @jobs = []
    restart_jobs
  end
end