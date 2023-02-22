class GFA::Field::Json < GFA::Field
  CODE = :J
  REGEX = /^[ !-~]+$/

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end
end
