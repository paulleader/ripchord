class Handbrake
  def convert(mkv, mp4, preset)
    cmd = "HandBrakeCLI -i #{mkv} -o #{mp4} --preset='#{preset}'"
    @log.info "Handbrake: #{cmd}"

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      until (stdout_line = stdout.gets).nil? do
        unless stdout_line =~ /Encoding: task 1 of 1/
          @log.info stdout_line
        end
      end
    end
    
  end
  
  def initialize(logger)
    @log = logger
  end
  
  def success?
    File.exists? output_filename
  end
end
