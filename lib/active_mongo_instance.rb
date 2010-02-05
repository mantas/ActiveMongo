ActiveMongo::Base.class_eval do
  def initialize(*attr)
    @vars = []
    
    attrs = (attr[0] || {})
    
    if self.class.attr_accessible_get.any?
      attrs.delete_if {|key, value| !self.class.attr_accessible_get.include?(key.to_sym) }
    end
    
    attrs.merge!(attr[1][:scope]) if attr[1] && attr[1][:scope]
    
    attrs.each do |key, value|
      self.set_var(key, value)
    end
    
    _run_initializer_callbacks :after
  end
  
  def to_json
    to_hash.to_json
  end
  
  def to_hash
    h = {}
    
    @vars.each do |var|
      h[var] = instance_variable_get("@#{var}")
    end
    
    h.each do |key, value|
      if key.to_s.match(/\_id$/) && value.class == String
        h[key] = Mongo::ObjectID.from_string(value)
      end
    end
    
    
    return h
  end
  
  def save(do_validate = true)
    
    def do_save
      hash = self.to_hash

      if self.class.attr_clear_get.any?
        hash.delete_if {|key, value| self.class.attr_clear_get.include?(key.to_sym) }
      end

      id = self.class.collection.save(hash)

      self.set_var("_id", id) if self._id.nil?
    end
    
    if self.new_record?
      
      _run_create_callbacks do
        _run_save_callbacks do
        
          if !do_validate || self.valid?
        
            do_save
          
          else
            return false
          end
        end
      end
      
    else
      
      _run_update_callbacks do
        _run_save_callbacks do
        
          if !do_validate || self.valid?
        
            do_save
          
          else
            return false
          end
        end
      end
      
      
    end
    
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
  
  def unset(var, do_not_save = false)
    self.set_var(var, nil)
    
    @vars.delete var.to_sym
    
    return false if self.new_record? || do_not_save
    
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