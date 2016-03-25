require "test_helper"
require "gfa/parser"

class ParserTest < Test::Unit::TestCase
   
  def setup
    $sample = File.expand_path("../fixtures/sample.gfa",__FILE__)
    $loop   = File.expand_path("../fixtures/loop.gfa",__FILE__)
  end
  
  def test_load
    assert_respond_to(GFA, :load)
    pre_fhs  = ObjectSpace.each_object(IO).count{ |i| not i.closed? }
    sample   = GFA.load($sample)
    post_fhs = ObjectSpace.each_object(IO).count{ |i| not i.closed? }
    assert_equal(pre_fhs, post_fhs)
    assert_equal(sample.headers.size, 1)
    assert_equal(sample.segments.size, 6)
    assert_equal(sample.links.size, 4)
    assert(sample.containments.empty?)
    assert(sample.paths.empty?)
    assert_respond_to(sample, :records)
  end
  
  def test_version_suppport
    gfa = GFA.new
    assert_raise { gfa.set_gfa_version("0.9") }
    assert_raise { gfa.set_gfa_version("1.1") }
    assert_nothing_raised { gfa.set_gfa_version("1.0") }
  end
  
  def test_line_by_line
    gfa = GFA.new
    assert_respond_to(gfa, :<<)
    # Empty
    gfa << " "
    assert(gfa.empty?)
    gfa << "H"
    assert(gfa.empty?)
    # Segment
    assert_equal(gfa.segments.size, 0)
    gfa << "S	1	ACTG"
    assert(!gfa.empty?)
    assert_equal(gfa.segments.size, 1)
    # Version
    assert_nil(gfa.gfa_version)
    gfa << GFA::Record::Header.new("VN:Z:1.0")
    assert_equal(gfa.gfa_version, "1.0")
  end

end
