class ResponseError
  attr_accessor :code, :message
  
  def initialize(code, message)
    @code = code
    @message = message
  end
  
  def self.is_error object
    if object.class == ResponseError
      return true
    else
      return false
    end
  end
end