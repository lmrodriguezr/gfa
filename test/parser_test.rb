require "test_helper"
require "gfa/parser"

class ParserTest < Test::Unit::TestCase
   
  def setup
    $sample = File.expand_path("../fixtures/sample.gfa",__FILE__)
    $loop   = File.expand_path("../fixtures/loop.gfa",__FILE__)
  end

  def test_load
    assert_respond_to(GFA, :load)
    sample = GFA.load($sample)
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
    # Segment
    assert_equal(gfa.segments.size, 0)
    gfa << "S	1	ACTG"
    assert_equal(gfa.segments.size, 1)
    # Version
    assert_nil(gfa.gfa_version)
    gfa << "H	VN:Z:1.0"
    assert_equal(gfa.gfa_version, "1.0")
  end

end
