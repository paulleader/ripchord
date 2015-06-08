class JobState
  STATES = [:start, :initializing, :ripping, :converting, :installing, :cleanup, :finished]
  
  include Comparable
  
  attr_accessor :state
  attr_reader :area
  
  def ===(other)
    Log.info "Comparing #{self.state} to #{other}"
    @state == other
  end
  
  def pickle
    data = {
      state: @state,
      title: @title
    }
    File.open(state_file, 'w' ) do |out|
      YAML.dump( data, out )
    end
  end
  
  def title
    @title
  end
  
  def title=(t)
    @title = t
    pickle
  end
  
  def next_state
    if @state
      i = STATES.find_index(@state) + 1
      STATES[i]
    else
      @state = :start
    end
  end
  
  def step!
    @state = next_state
    pickle
  end
  
  def failed!
    @state = :failed
    pickle
  end
  
  def failed?
    @state == :failed
  end
    
  def last?
    @state == :finished
  end
  
  def state_file
    area.state_file
  end
  
  def state_file_exists?
    File.exist?(state_file)
  end
  
  def state_yaml
    YAML.load(File.read(state_file))
  end
  
  def load_state
    yaml = state_yaml
    @state = yaml[:state].to_sym
    @title = yaml[:title]
  end
  
  def set_initial_state
    @state = :start
  end
    
  def initialize(working_area)
    @area = working_area
    if state_file_exists?
      load_state
    else
      set_initial_state
    end
  end
end