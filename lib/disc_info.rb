class DiscInfo
  def title
    @log.info "Get title"
    cmd = "blkid -o value -s LABEL #{@device}"
    
    @title = `#{cmd}`.chomp
    @log.info "Got #{@title}"
    if @title.nil? or @title.length == 0
      @title = nil
    else
      @title.gsub!(/[^A-Za-z0-9_\-]/, '')
      @title.gsub!(/\s+/, ' ')
    end
    @title
  end
  
  def initialize(logger, device)
    @log = logger
    @device = device
  end
end