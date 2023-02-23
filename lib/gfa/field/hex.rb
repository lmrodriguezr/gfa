class GFA::Field::Hex < GFA::Field
  CODE = :H
  REGEX = /[0-9A-F]+/
  NATIVE_FUN = :to_i

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

  def to_i
    value.to_i(16)
  end

  def to_f
    to_i.to_f
  end

  def equivalent?(field)
    if field.is_a? GFA::Field::NumArray
      return field.size == 1 && field.first.to_i == value
    end

    super
  end
end
