class Pipeline

  def initialize(log, options)
    @options = options
    @log = log
    
    @working_area_dir = @options.working_directory
    @area = WorkingArea.new(@log, @working_area_dir)
    @disc = DiscInfo.new(@log, options.device)
    
    @log.info "Title: #{@disc.title}"
  end
  
  def identify
    @title = @disc.title
  end
  
  def rip
    @make_mkv = MakeMKV.new(@log, @title, @options.disc, @area.ripping_dir)
    @make_mkv.rip
    @area.move_to_transcoding(@title)
  end

  def convert
    @handbrake = Handbrake.new(@log)
    @handbrake.convert(@area.ripped_file(@title), @area.converting_file(@title), @options.preset)
  end
  
  def install
    FileUtils.move(@area.converting_file(@title), @options.destination_directory)
  end
  
  def run
    identify
    rip
    convert
    install
  end
  
end
