class GFA::Field::Float < GFA::Field
  CODE = :f
  REGEX = /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f.to_f
  end
end
