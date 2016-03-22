class GFA::Field::SigInt < GFA::Field
   CODE = :i
   REGEX = /^[-+]?[0-9]+$/
   def initialize(f)
      GFA::assert_format(f, regex, "Bad #{type}")
      @value = f.to_i
   end
end
