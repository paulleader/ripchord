require 'logger'

class Log
  def self.set_out(location)
    @@location = location
  end
  
  def self.set_level(level)
    self.logger.level = Logger.const_get(level.upcase)
  end
  
  def self.logger
    @@log ||= Logger.new(@@location, 10, 1024000)
  end
  
  def self.info(message)
    logger.info message
  end

  def self.debug(message)
    logger.debug message
  end
end
