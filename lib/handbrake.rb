class Handbrake
  def convert(mkv, mp4, preset)
    cmd = "HandBrakeCLI -i #{mkv} --verbose -o #{mp4} --preset='#{preset}'"
    @log.info "Starting HandBrakeCLI"
    @log.info cmd

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      until (stdout_line = stdout.gets).nil? do
        @log.info stdout_line
      end
    end

    @log.info "Finished conversion"
  end
  
  def initialize(logger)
    @log = logger
  end
  
  def success?
    File.exists? output_filename
  end
end
