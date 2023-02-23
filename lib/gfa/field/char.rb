class GFA::Field::Char < GFA::Field
  CODE = :A
  REGEX = /[!-~]/
  NATIVE_FUN = :to_s

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end
end
