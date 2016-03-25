class GFA::Field::String < GFA::Field
  CODE = :Z
  REGEX = /^[ !-~]+$/
   
  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

end
