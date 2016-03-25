require "test_helper"
require "gfa/parser"

class ParserTest < Test::Unit::TestCase

  def setup
    $rec_h = GFA::Record::Header.new("VN:Z:1.0")
    $rec_p = GFA::Record::Path.new("a", "b", "*")
  end

  def test_class_methods
    assert_respond_to(GFA::Record, :CODES)
    assert_respond_to(GFA::Record, :TYPES)
  end

  def test_to_s
    assert_equal("H\tVN:Z:1.0", $rec_h.to_s)
    assert_equal("P\ta\tb\t*",  $rec_p.to_s)
  end

  def test_hash
    other_h = GFA::Record::Header.new("VN:Z:1.0")
    assert_equal($rec_h.hash, other_h.hash)
    assert_equal($rec_h, other_h)
  end
  
  def test_reserved_fields
    assert_nothing_raised do
      GFA::Record::Path.new("a", "b", "*", "smile:Z:(-:")
      GFA::Record::Header.new("Ooo:i:3")
      GFA::Record::Header.new("oOo:i:2")
      GFA::Record::Header.new("ooO:i:1")
    end
    assert_raise do
      GFA::Record::Header.new("OOPS:i:3")
    end
  end

  def test_header
  end

  def test_segment
  end

  def test_link
    l = GFA::Record::Link.new("Seg1","+","Seg2","-","*","NM:i:123")
    assert_equal("+", l.from_orient.value)
    assert_equal(123, l[:NM].value)
    assert(l.from?("Seg1"))
    assert(l.from?("Seg1", "+"))
    assert(l.to?("Seg2", "-"))
    assert(! l.from?("Seg2"))
    assert(! l.from?("Seg1", "-"))
  end

  def test_containment
    assert_raise do
      GFA::Record::Containment.new("Seg1","+","Seg2","-","*","RC:i:123")
    end
    c = GFA::Record::Containment.new("Seg1","+","Seg2","-","10","*","RC:i:123")
    assert_equal("+", c.from_orient.value)
    assert_equal(10, c.pos.value)
    assert_equal(123, c[:RC].value)
  end

  def test_path
    assert_raise do
      GFA::Record::Path.new("PathA","SegB\t","*")
    end
    p = GFA::Record::Path.new("PathA","SegB","*")
    assert_equal("*", p.cigar.value)
  end

end
