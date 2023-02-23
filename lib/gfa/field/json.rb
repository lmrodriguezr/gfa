class GFA::Field::Json < GFA::Field
  CODE = :J
  REGEX = /[ !-~]+/
  NATIVE_FUN = :to_s

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

  def equivalent?(field)
    # TODO
    # We should parse the contents when comparing two GFA::Field::Json to
    # evaluate equivalencies such as 'J:{ "a" : 1 }' ~ 'J:{"a":1}' (spaces)
    # or 'J:{"a":1,"b":2}' ~ 'J:{"b":2,"a":1}' (element order)
    super
  end
end
