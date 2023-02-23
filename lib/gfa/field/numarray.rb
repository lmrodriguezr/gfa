class GFA::Field::NumArray < GFA::Field
  CODE = :B
  REGEX = /[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+/
  NATIVE_FUN = :to_a

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

  def modifier
    value[0]
  end

  def modifier_fun
    modifier == 'f' ? :to_f : :to_i
  end

  def array
    @array ||= value[2..-1].split(',').map(&modifier_fun)
  end

  alias to_a array

  %i[empty? size count length first last].each do |i|
    define_method(i) { array.send(i) }
  end

  def number_type
    {
      c: 'int8_t',   C: 'uint8_t',
      s: 'int16_t',  S: 'uint16_t',
      i: 'int32_t',  I: 'uint32_t',
      f: 'float'
    }[modifier.to_sym]
  end

  def equivalent?(field)
    return true if eql?(field)

    if field.respond_to?(:to_a)
      field.to_a.map(&modifier_fun) == array
    elsif size == 1 && field.respond_to?(modifier_fun)
      field.send(modifier_fun) == first
    else
      false
    end
  end
end
