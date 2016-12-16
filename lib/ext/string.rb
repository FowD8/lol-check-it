class String
  def to_symbol
    self.underscore.to_sym
  end
end
