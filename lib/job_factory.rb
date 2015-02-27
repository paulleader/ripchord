require 'pidfile'

class JobFactory
  
  attr_reader :already_running
  
  def _send_signal
    @pid = PidFile.pid
    @log.info "JobFactory: Sending signal USR1 to process #{@pid}"
    Process.kill("USR1", @pid)
  end
  
  def _set_trap
    @pidfile = PidFile.new
    @log.info "JobFactory: Waiting for signal, pid = #{@pidfile.pid}"
    Signal.trap("USR1") do
      _start_job
    end
  end
  
  def _new_job
    Job.new.tap do |j|
      j.disc = @options.disc
      j.device = @options.device
      j.preset = @options.preset
      j.destination_directory = @options.destination_directory
      j.state = :new
    end
  end
    
  def jobs_started
    @jobs.length
  end
  
  def running_jobs
    @jobs.select {|j| j.state }.length
  end
  
  def work_in_progress?
    0 < running_jobs
  end
  
  def _add_job(job)
    @queue << job
    @jobs << job
  end
  
  def _start_job
    _add_job(_new_job)
  end
  
  def _startup
    @log.info 'JobFactory starting up'
    if PidFile.pidfile_exists?
      _send_signal
      @already_running = true
    else
      _set_trap
      _start_job
      @already_running = false
    end
  end
  
  def initialize(queue, options, logger)
    @log = logger
    @queue = queue
    @options = options
    @jobs = []
    _startup
  end
end