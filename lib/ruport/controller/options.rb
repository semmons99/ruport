require "ostruct"              

# Structure for holding controller options.  
# Simplified version of HashWithIndifferentAccess
class Ruport::Controller::Options < OpenStruct 
         
  if RUBY_VERSION < "1.9"
    private :id   
  end
  
  # Returns a Hash object.  Use this if you need methods other than []
  def to_hash
    @table
  end            
  # Indifferent lookup of an attribute, e.g.
  #
  #  options[:foo] == options["foo"]
  def [](key)
    send(key)
  end 
  
  # Sets an attribute, with indifferent access.
  #  
  #  options[:foo] = "bar"  
  #
  #  options[:foo] == options["foo"] #=> true
  #  options["foo"] == options.foo #=> true
  #  options.foo #=> "bar"
  def []=(key,value)
    send("#{key}=",value)
  end
end
