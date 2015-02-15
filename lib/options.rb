class Options

  attr_reader :log_file
  attr_reader :working_directory
  attr_reader :disc
  attr_reader :device
  attr_reader :extension
  attr_reader :preset
  attr_reader :destination_directory

  def initialize
    @log_file = '/var/log/dvdrip.log'
    @working_directory = '/mnt/bigdisk/importer'
    @disc = 'disc:0'
    @device = '/dev/sr0'
    @extension = "mp4"
    @source_drive = "/dev/sr0"
    @preset = 'AppleTV 2'
    @destination_directory = '/mnt/bigdisk/Shared/Media/Movies'
        
    OptionParser.new do |opts|
      opts.banner = "Usage: ripdisk [--log foo.log]"

      opts.on("-l", "--log [LOG FILE]", "File to log to") do |opt|
        @log_file = opt
      end
      
      opts.on("-o", "--working [WORKING DIRECTORY]", "Working directory") do |opt|
        @working_directory = opt
      end
      
      opts.on("-o", "--destination [DESTINATION DIRECTORY]", "Directory to output final file") do |opt|
        @destination_directory = opt
      end
      
      opts.on("-s", "--disc [SOURCE DISC]", "Source disc to rip from") do |opt|
        @disc = opt
      end
      
      opts.on("-d", "--device [DEVICE]", "Source Device") do |opt|
        @device = opt
      end
      
      opts.on("-e", "--extension [EXTENSION]", "Output extension") do |opt|
        @extension = opt
      end

      opts.on("-p", "--preset [PRESET]", "Handbrake preset") do |opt|
        @preset = opt
      end
      
    end.parse!

    def summary
      [
        "Log file: #{@log_file}",
        "Working directory: #{@working_directory}",
        "Disc: #{@disc}",
        "Device: #{@device}",
        "Extension: #{@extension}",
        "Preset: #{@preset}"
      ].join("\n")
    end
  end
end