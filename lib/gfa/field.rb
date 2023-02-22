class GFA::Field
  # Class-level
  CODES = {
    A: :Char,
    i: :SigInt,
    f: :Float,
    Z: :String,
    J: :Json, # Excluding new-line and tab characters
    H: :Hex,
    B: :NumArray
  }
  TYPES = CODES.values
  TYPES.each { |t| require "gfa/field/#{t.downcase}" }

  [:CODES, :TYPES].each do |x|
    define_singleton_method(x) { const_get(x) }
  end
  
  def self.code_class(code)
    name = CODES[code.to_sym]
    raise "Unknown field type: #{code}." if name.nil?
    name_class(name)
  end

  def self.name_class(name)
    const_get(name)
  end
   
  # Instance-level

  attr :value

  def type ; CODES[code] ; end
   
  def code ; self.class::CODE ; end
   
  def regex ; self.class::REGEX ; end
   
  def to_s(with_type=true)
    "#{"#{code}:" if with_type}#{value}"
  end
   
  def hash
    value.hash
  end

end
