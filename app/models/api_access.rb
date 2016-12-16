class ApiAccess < ActiveRecord::Base
  def self.can_access?
    time_passed = self.safe_time_passed
    
    return true if time_passed.nil?
    
    time_passed > 10
  end
  
  def self.safe_time_passed
    accessed = self.last(10)
    
    return (Time.now - accessed.first.created_at) if accessed.count == 10
  end
  
  def self.sleep_clear
    time_passed = self.safe_time_passed
    
    return if time_passed.nil? || time_passed > 10
    
    delta_time = 10 - time_passed
    
    puts "Sleeping for #{(delta_time+1).round 2}s"
    sleep delta_time + 1
  end
end