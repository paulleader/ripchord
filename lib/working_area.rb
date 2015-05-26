require 'fileutils'
require 'securerandom'

class NoWorkingDirectory < StandardError
end

class WorkingArea
  
  attr_reader :job_id
  
  def subdir(purpose)
    File.join(root, purpose)
  end
  
  def state_file
    File.join(root, 'state.yml')
  end

  def ripped_directory
    subdir('ripped')
  end
  
  def converted_directory
    subdir('converted')
  end
    
  def all_ripped_files
    files = Dir.entries(ripped_directory).reject {|x| x == '.' || x == '..'}
    files.collect do |ripped_file_name|
      File.join(ripped_directory, ripped_file_name)
    end
  end
      
  def ripped_file
    all_ripped_files.max do |a, b|
      File.size(a) <=> File.size(b)
    end
  end

  def converted_file
    File.join(converted_directory, 'converted.mp4')
  end
  
  def check_working_directory
    Log.info "Checking working directory"
    raise NoWorkingDirectory, @working_root unless Dir.exist? @working_root
  end

  def make_subdirectories
    ['ripped', 'converted'].each do |stage, path|
      directory = subdir(stage)
      unless Dir.exist? directory
        Log.info "Creating #{directory}"
        Dir.mkdir directory
      end
    end
  end

  def working_root_path
    File.join(@working_root, job_id)
  end

  def new_root_directory
    check_working_directory
    unless Dir.exists? working_root_path
      Dir.mkdir working_root_path
    end
    working_root_path
  end

  def cleanup
    if Dir.exists? @root_directory
      FileUtils.rm_rf(@root_directory)
    end
  end

  def root
    @root_directory ||= new_root_directory
  end
  
  def self.existing_job_ids(working_root)
    Dir.entries(working_root).reject {|x| x =~ /\./}
  end

  def initialize(working_root, uid = nil)
    @job_id ||= (uid || SecureRandom.uuid)
    @working_root = working_root
    make_subdirectories if uid
  end

end
