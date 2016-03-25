require "test_helper"

class CommonTest < Test::Unit::TestCase
   def test_empty
      gfa = GFA.new
      assert(gfa.empty?)
      assert_equal(gfa, GFA.new)
   end
end
