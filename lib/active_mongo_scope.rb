ActiveMongo::Base.class_eval do
  def self.with_scope(attrs)
    @name = (self.name || @name)
    cloned = self.clone.with_scope_set(attrs)
    
    return cloned
  end
  
  def self.with_scope_set(attrs)
    @scope ||= {}
    
    @scope.merge! attrs
    
    return self
  end
end