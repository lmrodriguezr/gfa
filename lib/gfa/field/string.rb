class GFA::Field::String < GFA::Field
  CODE = :Z
  REGEX = /[ !-~]+/
  NATIVE_FUN = :to_s

  def to_f
    value.to_f
  end

  def to_i(base = 10)
    value.to_i(base)
  end

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end
end
