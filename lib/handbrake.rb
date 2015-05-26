class Handbrake
  def self.semaphore
    @@semaphore ||= Mutex.new
  end

  def self.convert(mkv, mp4, preset)
    Log.info "Converting"
    semaphore.synchronize do
      cmd = "HandBrakeCLI -i #{mkv} -o #{mp4} --preset='#{preset}'"
      Log.info "Handbrake: #{cmd}"

      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
        until (stdout_line = stdout.gets).nil? do
          unless stdout_line =~ /Encoding: task 1 of 1/
            Log.info stdout_line
          end
        end
      end
    end
  end
end
