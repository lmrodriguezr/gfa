class GFA::Field::Hex < GFA::Field
  CODE = :H
  REGEX = /^[0-9A-F]+$/

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

end
