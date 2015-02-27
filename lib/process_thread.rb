class ProcessThread

  def _stage
    word = self.class.name
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  def _next_job
    @logger.info "#{self.class}: Waiting for job on #{@in} (#{@in.length} jobs in queue)"
    job = @in.pop
    job.state = _stage
    job
  end
  
  def running?
    @running
  end

  def _thread
    @logger.info "Starting thread #{self.class}"
    Thread.new do
      begin
        while job = _next_job do
          @logger.info "#{self.class}: Got job #{job.inspect}"
          if job
            _process(job)
          end
          @out << job
        end
      rescue Exception => e
        @logger.info "Exception raised in #{self.class}"
        @logger.info e.inspect
        @logger.info e.backtrace
      end
    end
  end

  def _process
    raise NotImplementedError
  end
  
  def _start
    @thread ||= _thread
  end

  def initialize(inbound, outbound, working_area, logger)
    @in = inbound
    @out = outbound
    @logger = logger
    @thread = _thread
    @working_area = working_area
    _start
  end

end