require_relative 'disc'
require_relative 'handbrake'
require_relative 'notifier'
require_relative 'job_state'
require 'yaml'

class Job
  attr_accessor :state

  def _initialize
    Disc.semaphore.synchronize do
      @state.title ||= Disc.title
    end
  end

  def _rip
    Log.info "Start ripping"
    Disc.semaphore.synchronize do
      @state.title ||= Disc.title
      Log.info "Rippeing #{@title}"
      Disc.rip(@working_area.ripped_directory)
    end
    Notifier.ripped(self).deliver
  end
  
  def _convert
    Log.info "Start conversion"
    Handbrake.convert(@working_area.ripped_file, @working_area.converted_file, @options.preset)
    Notifier.converted(self).deliver
  end
  
  def destination_file
    @options.destination_directory + '/' + @state.title + '.mp4'
  end
  
  def _install
    Log.info "Installing"
    Log.info "Converted:"
    Log.info @working_area.converted_file
    Log.info "Destination:"
    Log.info destination_file
    FileUtils.move(@working_area.converted_file, destination_file)
  end
  
  def _cleanup
    @working_area.cleanup
  end
      
  def _process_disc
    until @state.last?
      Log.info "State = #{state.state}"
      case @state.state
      when :start
        Log.info "Starting job #{@working_area.job_id}"
      when :initializing
        nil
      when :ripping
        _rip
      when :converting
        _convert
      when :installing
        _install
      when :cleanup
        _cleanup
      when :finished
        Log.info "Finished"
        nil
      else
        raise "No match for #{state.state}"
      end
      @state.step!
    end
  end
  
  def _run
    @thread = Thread.new {
      _process_disc
    }
  end
  
  def running?
    @thread.alive?
  end
  
  def preset
    @options.preset
  end
  
  def destination_directory
    @options.destination_directory
  end
  
  def notification_address
    @options.notification_address
  end
  
  def notifications_from
    @options.notifications_from
  end
  
  def uid
    @working_area.job_id
  end
  
  def title
    @state.title
  end
  
  def load_state
    job_info = YAML.load_file(file)
    @state = JobState.new(job[:state].to_sym)
    @title = job[:title]
  end

  def initialize(options, uid: nil)
    @options = options
    @working_area = WorkingArea.new(@options.working_directory, uid)
    
    @state = JobState.new(@working_area)
    begin
      _run
    rescue e
      Log.info "Job #{self.uid} Failed"
      Log.info e.message
      Log.info e.backtrace.join("\n")
      raise e
    end
  end
end