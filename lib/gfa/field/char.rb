class GFA::Field::Char < GFA::Field
   CODE = :A
   REGEX = /^[!-~]$/
   def initialize(f)
      GFA::assert_format(f, regex, "Bad #{type}")
      @value = f
   end
end
