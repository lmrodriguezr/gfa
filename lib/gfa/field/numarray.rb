class GFA::Field::NumArray < GFA::Field
   CODE = :B
   REGEX = /^[cCsSiIf](,[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)+$/
   attr :modifier, :array  
   def initialize(f)
      GFA::assert_format(f, regex, "Bad #{type}")
      @value = f
      @modifier = f[1]
      @array = f[1..-1].split(/,/).map{ |x| x.to_i }
   end

   def as_a ; array ; end
end
