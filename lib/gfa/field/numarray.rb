class GFA::Field::NumArray < GFA::Field
  CODE = :B
  REGEX = /^[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+$/

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

  def modifier ; value[0] ; end

  def array ; value[2..-1].split(/,/) ; end

  alias as_a array

  def number_type
    {
      c: 'int8_t',   C: 'uint8_t',
      s: 'int16_t',  S: 'uint16_t',
      i: 'int32_t',  I: 'uint32_t',
      f: 'float'
    }[modifier.to_sym]
  end
end
