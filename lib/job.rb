class Job

  attr_accessor :state
  attr_accessor :title
  attr_accessor :disc
  attr_accessor :device
  attr_accessor :preset
  attr_accessor :destination_directory

  def summary
    [:title, :disc, :device, :preset, :destination].collect do |k|
      "#{k.to_s}: #{self.send(k)}"
    end.join("\n")
  end
end