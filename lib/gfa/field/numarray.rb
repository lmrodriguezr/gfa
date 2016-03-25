class GFA::Field::NumArray < GFA::Field
  CODE = :B
  REGEX = /^[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+$/

  def initialize(f)
    GFA.assert_format(f, regex, "Bad #{type}")
    @value = f
  end

  def modifier ; value[0] ; end

  def array ; value[2..-1].split(/,/) ; end
  
  alias as_a array

end
