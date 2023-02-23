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

  %i[CODES TYPES].each do |x|
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

  def self.[](string)
    code, value = string.split(':', 2)
    code_class(code).new(value)
  end

  # Instance-level

  attr :value

  def type
    CODES[code]
  end

  def code
    self.class::CODE
  end

  def regex
    self.class::REGEX
  end

  def native_fun
    self.class::NATIVE_FUN
  end

  def to_native
    native_fun == :to_s ? to_s(false) : send(native_fun)
  end

  def to_s(with_type = true)
    "#{"#{code}:" if with_type}#{value}"
  end

  def hash
    value.hash
  end

  ##
  # Evaluate equivalency of contents. All the following fields are distinct but
  # contain the same information, and are therefore considered equivalent:
  # Z:123, i:123, f:123.0, B:i,123, H:7b
  #
  # Note that the information content is determined by the class of the first
  # operator. For example:
  # - 'i:123' ~ 'f:123.4' is true because values are compared as integers
  # - 'f:123.4' ~ 'i:123' if false because values are compared as floats
  def equivalent?(field)
    return true if eql?(field) # Might be faster, so testing this first

    if field.respond_to?(native_fun)
      if field.is_a?(GFA::Field) && native_fun == :to_s
        field.to_s(false) == to_native
      else
        field.send(native_fun) == to_native
      end
    else
      field == value
    end
  end

  ##
  # Non-equivalent to +field+, same as +!equivalent?+
  def !~(field)
    !self.~(field)
  end

  ##
  # Same as +equivalent?+
  def ~(field)
    equivalent?(field)
  end

  ##
  # Evaluate equality. Note that fields with equivalent values evaluate as
  # different. For example, the following fields have equivalent information,
  # but they all evaluate as different: Z:123, i:123, f:123.0, B:i,123, H:7b.
  # To test equivalency of contents instead, use +equivalent?+
  def eql?(field)
    if field.is_a?(GFA::Field)
      type == field.type && value == field.value
    else
      field.is_a?(value.class) && value == field
    end
  end

  ##
  # Same as +eql?+
  def ==(field)
    eql?(field)
  end
end
