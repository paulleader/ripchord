require 'open3'

class MakeMKV

  def self.rip(title, destination, disc = 'disc:0')
    self.new(title, destination, disc).rip
  end

  def initialize(title, destination, disc)
    @title = title
    @disc = disc
    @destination = destination
  end
  
  def build_target_dir
    unless File.exist? rip_directory
      Dir.mkdir rip_directory
    end
  end

  def rip_directory
    File.join(@destination, @title)
  end

  def rip
    Log.info "Ripping"
    Log.info "======="
    Log.info "Title: #{@title}"
    Log.info "Destination: #{rip_directory}"
    build_target_dir
    cmd = "/usr/bin/makemkvcon -r --decrypt --directio=true --noscan --minlength=1400 mkv disc:0 all #{rip_directory}"
    Log.info cmd

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      until (stdout_line = stdout.gets).nil? do
        Log.info stdout_line
      end
    end
  end

end