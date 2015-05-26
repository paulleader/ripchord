require 'optparse'
require 'yaml'

class MissingOption < StandardError
end

class Options

  attr_reader :log_file
  attr_reader :working_directory
  attr_reader :disc
  attr_reader :device
  attr_reader :extension
  attr_reader :preset
  attr_reader :destination_directory
  attr_reader :smtp
  attr_reader :notification_address
  attr_reader :notifications_from
  attr_reader :config_file_location
  attr_reader :show_config

  def default_options
    {
      config_file_location:  '/etc/ripchord.yml',
      log_file:     '/var/log/ripchord.log',
      disc:         'disc:0',
      device:       '/dev/sr0',
      extension:    "mp4",
      source_drive: "/dev/sr0",
      preset:       'AppleTV 2',
      show_config:  false
    }
  end

  def parse_command_line_options
    options = Hash.new
    
    OptionParser.new do |opts|
      opts.banner = "Usage: ripdisk [--log foo.log]"

      opts.on("-c", "--config [CONFIG FILE]", "Config file in YAML format") do |opt|
        options[:config_file_location] = opt
      end

      opts.on("-l", "--log [LOG FILE]", "File to log to") do |opt|
        options[:log_file] = opt
      end
      
      opts.on("-w", "--working [WORKING DIRECTORY]", "Working directory") do |opt|
        options[:working_directory] = opt
      end
      
      opts.on("-o", "--destination [DESTINATION DIRECTORY]", "Directory to output final file") do |opt|
        options[:destination_directory] = opt
      end
      
      opts.on("-s", "--disc [SOURCE DISC]", "Source disc to rip from") do |opt|
        options[:disc] = opt
      end
      
      opts.on("-d", "--device [DEVICE]", "Source Device") do |opt|
        options[:device] = opt
      end
      
      opts.on("-e", "--extension [EXTENSION]", "Output extension") do |opt|
        options[:extension] = opt
      end

      opts.on("-p", "--preset [PRESET]", "Handbrake preset") do |opt|
        options[:preset] = opt
      end
      
      opts.on('-z', "--show-config", "Display the configuration and exit") do |opt|
        options[:show_config] = opt
      end
      
    end.parse!
    
    options
  end
  
  def command_line_options
    @command_line_options ||= parse_command_line_options
  end

  def config_file_contents
    @config_contents ||= File.read(@config_file_location)
  end

  def config_file_options
    if File.exists? @config_file_location
      YAML.load(config_file_contents).symbolize_keys
    else
      {}
    end
  end

  def initialize
    options = default_options.merge(command_line_options)
    
    @config_file_location = options[:config_file_location]
    options.merge! config_file_options
    
    @log_file = options[:log_file]
    @working_directory = options[:working_directory]
    @disc = options[:disc]
    @device = options[:device]
    @extension = options[:extension]
    @source_drive = options[:source_drive]
    @preset = options[:preset]
    @destination_directory = options[:destination_directory]

    @smtp = options[:smtp]
    @notification_address = options[:notification_address]
    @notifications_from = options[:notifications_from]   
    @show_config = options[:show_config] 

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