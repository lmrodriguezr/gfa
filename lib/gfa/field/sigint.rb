class GFA::Field::SigInt < GFA::Field
  CODE = :i
  REGEX = /[-+]?[0-9]+/
  NATIVE_FUN = :to_i

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f.to_i
  end

  def to_i
    value
  end

  def equivalent?(field)
    if field.is_a?(GFA::Field::NumArray)
      return field.size == 1 && field.first.to_i == value
    end

    super
  end
end
