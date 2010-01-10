ActiveMongo::Base.class_eval do
  def initialize(*attr)
    @vars = []
    
    attrs = attr[0] || {}
    
    if self.class.attr_accessible_get.any?
      attrs.delete_if {|key, value| !self.class.attr_accessible_get.include?(key.to_sym) }
    end
    
    attrs.merge!(attr[1][:scope]) if attr[1] && attr[1][:scope]
    
    attrs.each do |key, value|
      self.set_var(key, value)
    end
  end
  
  def to_json
    to_hash.to_json
  end
  
  def to_hash
    h = {}
    
    @vars.each do |var|
      h[var] = instance_variable_get("@#{var}")
    end
    
    return h
  end
  
  def save(do_validate = true)
    return false if do_validate && !self.valid?
    
    id = self.class.collection.save(self.to_hash)
    
    self.set_var("_id", id) if self._id.nil?
    
    return true
  end
  
  def destroy
    return true if self.new_record?
    
    self.class.destroy_all :_id => self._id
  end
  
  def new_record?
    @_id.nil?
  end
  
  def set_var(var, val)
    if var.to_s == "_id" && val.class != Mongo::ObjectID
      val = Mongo::ObjectID.from_string(val)
    end
    
    instance_variable_set("@#{var}", val)
    @vars.push(var.to_sym).uniq!
  end
  
  def get_var(var)
    instance_variable_get("@#{var}")
  end
  
  def update_attributes(*attrs)
    attrs = attrs[0]
    if self.class.attr_accessible_get.any?
      attrs.delete_if {|key, value| !self.class.attr_accessible_get.include?(key.to_sym) }
    end
    
    attrs.each do |key, value|
      self.set_var(key, value)
    end
    
    return self
  end
  
  def unset(var)
    self.set_var(var, nil)
    
    @vars.delete var.to_sym
    
    return false if self.new_record?
    
    hash = self.class.collection.find_one self._id
    
    hash.delete(var)
    
    self.class.collection.save(hash)
    
    
    true
  end
  
  def method_missing(m, *attrs, &block)
    if m.to_s.match(/\=$/) && attrs.length > 0
      var_name = m.to_s.sub /\=$/, ""
      
      self.set_var(var_name, attrs[0])
    elsif self.class.internal_has_manies_get(m.to_sym)
      return self.has_many_hit(m, self.class.internal_has_manies_get(m) )
    elsif @vars.include? m.to_sym
      begin
        var = self.get_var(m)
        error = false
      rescue
        error = true
      end
      
      return var unless error
    end
    
  end
end