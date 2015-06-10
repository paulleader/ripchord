require_relative 'make_mkv'
require 'securerandom'

class Disc
  def self.semaphore
    @@semaphore ||= Mutex.new
  end
  
  def self._blank_title?(title)
    title.nil? || title.gsub(/\s+/, '').empty?
  end
  
  def self._random_title
    "Unknown-#{SecureRandom.uuid}"
  end
  
  def self.get_title_from_disc
    cmd = "blkid -o value -s LABEL /dev/sr0"  
    title = `#{cmd}`.chomp
    if title.nil? or title.length == 0
      title = nil
    else
      title.gsub!(/[^A-Za-z0-9_\-]/, '')
      title.gsub!(/\s+/, ' ')
    end
    puts "TITLE: #{title}"
    if _blank_title?(title)
      _random_title
    else
      title
    end
  end
    
  def self.title
    self.get_title_from_disc
  end
    
  def self.rip(destination)
    MakeMKV.rip(title, destination)
    Disc.eject
  end
  
  def self.eject
    `eject`
  end
end