class Log
  def self.set_out(location)
    @@location = location
  end

  def self.logger
    @@log ||= Logger.new(@@location, 10, 1024000)
  end
  
  def self.info(message)
    logger.info message
  end
end
