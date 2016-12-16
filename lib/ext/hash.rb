class Hash
  def camelize_keys!
    update_keys!(:camelize, :lower)
  end

  def underscore_keys!
    update_keys!(:underscore)
  end
  
  def symbolize!
    update_keys!(:underscore)
  end

  def update_keys!(method, *args)
    self.keys.each do |key|
      updated_key = key.to_s.send(method, *args).to_sym
      self[updated_key] = self.delete(key)
      if self[updated_key].kind_of? Hash
        self[updated_key].update_keys!(method, *args)
      elsif self[updated_key].kind_of? Array
        self[updated_key].each do |arr|
          arr.update_keys!(method, *args)
        end
      end
    end
    self
  end
end