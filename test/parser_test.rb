require "test_helper"
require "gfa/parser"

class ParserTest < Test::Unit::TestCase

  def test_load
    assert_respond_to(GFA, :load)

    # Can load files and close pointers properly
    pre_fhs  = ObjectSpace.each_object(IO).count { |i| not i.closed? }
    assert_nothing_raised do
      GFA.load(fixture_path('sample1.gfa'))
    end
    assert_nothing_raised do
      GFA.load(fixture_path('sample2.gfa'))
    end
    assert_nothing_raised do
      GFA.load(fixture_path('sample3.gfa'))
    end
    assert_raise do
      GFA.load(fixture_path('sample4.gfa'))
    end
    post_fhs = ObjectSpace.each_object(IO).count { |i| not i.closed? }
    assert_equal(pre_fhs, post_fhs)
  end

  def test_records
    # Samples are properly parsed
    sample1 = GFA.load(fixture_path('sample1.gfa'))
    assert_equal(1, sample1.headers.size)
    assert_equal(6, sample1.segments.size)
    assert_equal(4, sample1.links.size)
    assert(sample1.containments.empty?)
    assert(sample1.paths.empty?)
    assert_respond_to(sample1, :records)
  end

  def test_comments
    path = fixture_path('sample2.gfa')
    sample = GFA.load(path)
    assert(sample.comments.empty?)
    sample = GFA.load(path, comments: true)
    assert(!sample.comments.empty?)
  end

  def test_index
    path = fixture_path('sample3.gfa')
    sample = GFA.load(path)
    assert(sample.path('first').is_a?(GFA::Record))
    assert(sample.paths['first'].is_a?(GFA::Record))
    assert_equal('first', sample.path('first')[2]&.value)
    assert(sample.indexed?)
    sample = GFA.load(path, index: false)
    assert_nil(sample.path('first'))
    assert(!sample.indexed?)
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
    gfa << "S\t1\tACTG\n"
    assert(!gfa.empty?)
    assert_equal(1, gfa.segments.size)

    # Version
    assert_nil(gfa.gfa_version)
    gfa << GFA::Record::Header.new('VN:Z:1.0')
    assert_equal('1.0', gfa.gfa_version)
  end
end
