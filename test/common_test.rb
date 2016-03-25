require "test_helper"

class CommonTest < Test::Unit::TestCase
   
  def test_assert_format
    assert_raise do
      GFA.assert_format("tsooq", /^.$/, "Not a char")
    end
    assert_nothing_raised do
      GFA.assert_format("z", /^.$/, "Not a char")
    end
  end
   
  def test_empty
    gfa = GFA.new
    assert(gfa.empty?)
    assert_equal(GFA.new, gfa)
  end

  def test_record_getters
    gfa = GFA.new
    assert_respond_to(gfa, :headers)
    assert_equal([], gfa.links)
    assert_nil( gfa.segment(0) )
  end

  def test_record_setters
    gfa = GFA.new
    assert_respond_to(gfa, :add_path)
    gfa.add_containment("zooq")
    assert_equal("zooq", gfa.records[:Containment].first)
  end

end
