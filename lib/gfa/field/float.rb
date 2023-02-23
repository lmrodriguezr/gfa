class GFA::Field::Float < GFA::Field
  CODE = :f
  REGEX = /[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?/
  NATIVE_FUN = :to_f

  def to_f
    value
  end

  def to_i
    value.to_i
  end

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f.to_f
  end

  def equivalent?(field)
    if field.is_a?(GFA::Field::NumArray)
      return field.size == 1 && field.first.to_f == value
    end

    super
  end
end
