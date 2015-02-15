class MakeMKV

  attr_accessor :title

  def initialize(logger, title, disc = 'disc:0', destination)
    @log = logger
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
    @log.info "Rip dir"
    @log.info @destination
    @log.info @title
    File.join(@destination, @title)
  end

  def rip
    @log.info "Ripping"
    @log.info "======="
    @log.info "Title: #{@title}"
    @log.info "Destination: #{rip_directory}"
    build_target_dir
    @log.info "Start ripping to #{rip_directory}"
    cmd = "/usr/bin/makemkvcon -r --decrypt --directio=true --noscan --minlength=1400 mkv disc:0 all #{rip_directory}"
    @log.info cmd

    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      until (stdout_line = stdout.gets).nil? do
        @log.info stdout_line
      end
    end
  end

end