require_relative 'job_collection'
require_relative 'working_area'
require_relative 'pid_file'

class ProcessController

  attr_reader :already_running

  def _send_signal
    @pid = PidFile.pid
    Log.debug @pid
    Log.debug "ProcessController: Sending signal USR1 to process #{@pid}"
    Process.kill("USR1", @pid)
  end
  
  def _set_trap
    @pidfile = PidFile.new
    Log.info "ProcessController: Waiting for signal, pid = #{@pidfile.pid}"
    Signal.trap("USR1") do
      @jobs.start_job
    end
  end
  
  def _startup
    Log.info 'ProcessController starting up'
    if PidFile.pidfile_exists?
      _send_signal
    else
      _set_trap
      @jobs = JobCollection.new(@options)
      if not @jobs.running?
        @jobs.start_job
      end
    end
  end

  def running?
    @jobs.running?
  end

  def initialize(options)
    @options = options
    _startup
  end
end