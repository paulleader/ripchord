require './lib/disc_info'
require './lib/handbrake'
require './lib/make_mkv'
require './lib/working_area'
require './lib/options'
require './lib/process_thread'
require './lib/ripper'
require './lib/transcoder'
require './lib/installer'
require './lib/job'
require './lib/job_factory'

class Pipeline
  
  def _build_queues
    @to_rip = Queue.new
    @to_transcode = Queue.new
    @to_install = Queue.new
    @completed = Queue.new  
  end
  
  def _build_pipeline
    @working_area = WorkingArea.new(Log, @options.working_directory)
    @ripper = Ripper.new(@to_rip, @to_transcode, @working_area, @log)
    @transcoder = Transcoder.new(@to_transcode, @to_install, @working_area, @log)
    @installer = Installer.new(@to_install, @completed, @working_area, @log)
  end
  
  def _terminate_threads
    @to_rip << nil
  end
  
  def _run_pipeline
    while @job_factory.work_in_progress?
      sleep 30
    end
    _terminate_threads
  end
  
  def _start
    unless @job_factory.already_running
      _build_pipeline
      _run_pipeline
    end
  end
  
  def initialize(options, log)
    @options = options
    @log = log
    
    _build_queues
    @job_factory = JobFactory.new(@to_rip, @options, @log)
    _start
  end
end