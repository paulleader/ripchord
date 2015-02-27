class NoWorkingDirectory < StandardError
end

class MissingInProgressTitle < StandardError
end

class WorkingArea

  SUBDIRECTORIES = {
    ripping: 'ripping',
    ripped: 'ripped',
    converting: 'converting',
    finished: 'finished'
  }

  def ripping_dir(title = nil)
    path = [@root, SUBDIRECTORIES[:ripping], title].compact
    File.join(path)
  end

  def ripped_dir(title = nil)
    path = [@root, SUBDIRECTORIES[:ripped], title].compact
    File.join(path)
  end
  
  def ripped_disc_directory(title)
    File.join(ripped_dir, title)
  end  
  
  def ripped_file(title)
    File.join(ripped_disc_directory(title), 'title00.mkv')
  end

  def cleanup_rip(title)
    FileUtils.rm_rf(ripped_disc_directory(title))
  end

  def converted_directory
    File.join(@root, SUBDIRECTORIES[:finished])
  end

  def converting_directory
    File.join(@root, SUBDIRECTORIES[:converting])
  end

  def converting_file(title)
    File.join(converting_directory, title + '.mp4')
  end
  
  def finished_file(title)
    File.join(converted_directory, title + '.mp4')
  end

  def check_working_directory
    @log.info "Checking working directory"
    raise NoWorkingDirectory, @root unless Dir.exist? @root
  end

  def subdir_path(stage)
    File.join(@root, SUBDIRECTORIES[stage])
  end

  def make_subdirectories
    SUBDIRECTORIES.each do |stage, path|
      unless Dir.exist? subdir_path(stage)
        @log.info "Creating #{subdir_path(stage)}"
        Dir.mkdir subdir_path(stage)
      end
    end
  end

  def rip_finished?(title)
    File.exist?( ripping_dir(title) )
  end

  def move_to_transcoding(title)
    if rip_finished? title
      FileUtils.move( ripping_dir(title), ripped_dir(title) )
    else
      raise MissingInProgressTitle, title
    end
  end
    
  def is_directory?(dir)
    (Dir.exist?(dir) && dir !~ /\/\.{1,2}$/)
  end
  
  def to_convert
    Dir.foreach(ripped_dir).select do |dir|
      is_directory? ripped_disc_directory(dir)
    end
  end

  def initialize(logger, root)
    @log = logger
    @root = root
    check_working_directory
    make_subdirectories
  end

end
