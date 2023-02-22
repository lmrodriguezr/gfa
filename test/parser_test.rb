require "test_helper"
require "gfa/parser"

class ParserTest < Test::Unit::TestCase
   
  def test_load
    sample_f = File.expand_path('../fixtures/sample.gfa', __FILE__)
    assert_respond_to(GFA, :load)
    pre_fhs  = ObjectSpace.each_object(IO).count{ |i| not i.closed? }
    sample   = GFA.load(sample_f)
    post_fhs = ObjectSpace.each_object(IO).count{ |i| not i.closed? }
    assert_equal(pre_fhs, post_fhs)
    assert_equal(1, sample.headers.size)
    assert_equal(6, sample.segments.size)
    assert_equal(4, sample.links.size)
    assert(sample.containments.empty?)
    assert(sample.paths.empty?)
    assert_respond_to(sample, :records)
  end
  
  def test_version_suppport
    gfa = GFA.new
    assert_raise { gfa.set_gfa_version('0.9') }
    assert_raise { gfa.set_gfa_version('2.1') }
    assert_nothing_raised { gfa.set_gfa_version('1.0') }
  end
  
  def test_line_by_line
    gfa = GFA.new
    assert_respond_to(gfa, :<<)
    # Empty
    gfa << ' '
    assert(gfa.empty?)
    gfa << 'H'
    assert(gfa.empty?)
    # Segment
    assert_equal(0, gfa.segments.size)
    gfa << "S\t1\tACTG"
    assert(!gfa.empty?)
    assert_equal(1, gfa.segments.size)
    # Version
    assert_nil(gfa.gfa_version)
    gfa << GFA::Record::Header.new('VN:Z:1.0')
    assert_equal('1.0', gfa.gfa_version)
  end

end
