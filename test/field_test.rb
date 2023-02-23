require "test_helper"

class FieldTest < Test::Unit::TestCase

  def test_char
    f = GFA::Field::Char.new('%')
    assert_equal('%', f.value)
    assert_raise { GFA::Field::Char.new(' ') }
    assert_raise { GFA::Field::Char.new('') }
    assert_raise { GFA::Field::Char.new('^.^') }
  end

  def test_sigint
  end

  def test_float
    f = GFA::Field::Float.new('1.3e-5')
    assert_equal(1.3e-5, f.value)
    assert_raise { GFA::Field::Float.new('e-5') }
  end

  def test_string
  end

  def test_hex
     f = GFA::Field::Hex.new('C3F0')
     assert_equal('C3F0', f.value)
     assert_raise { GFA::Field::Hex.new('C3PO') }
  end

  def test_numarray
    f = GFA::Field::NumArray.new('i,1,2,3')
    assert_equal([1, 2, 3], f.array)
    assert_equal('i', f.modifier)
    assert_raise { GFA::Field::NumArray.new('c,1,e,3') }
  end

  def test_equal
    f = GFA::Field::SigInt.new('123')
    j = GFA::Field::String.new('123')
    k = GFA::Field::Float.new('123')
    assert(f == 123)
    assert(123 == f)
    assert(f != 123.0)
    assert(f != '123')
    assert(f.eql?(123))
    assert(f != j)
    assert(f != k)
    assert(f != k.value)
    assert(f.value == k.value)
  end

  def test_equivalent
    # String comparisons
    assert(GFA::Field['Z:a'].~ GFA::Field['A:a'])
    assert(GFA::Field['Z:ab'] !~ GFA::Field['A:a'])
    assert(GFA::Field['Z:{"a":1}'].~ GFA::Field['J:{"a":1}'])
    assert(GFA::Field['J:{"a":1}'].~ GFA::Field['Z:{"a":1}'])

    # Numeric comparisons
    assert(GFA::Field['Z:123'].~ GFA::Field['i:123'])
    assert(GFA::Field['Z:123'].~ GFA::Field['i:123'])
    assert(GFA::Field['i:123'].~ GFA::Field['f:123'])
    assert(GFA::Field['f:123'].~ GFA::Field['B:i,123'])
    assert(GFA::Field['B:i,123'].~ GFA::Field['H:7B'])
    assert(GFA::Field['H:7B'].~ GFA::Field['f:123.0'])
    assert(GFA::Field['Z:123'] !~ GFA::Field['H:7B']) # In hex-space!
    assert(GFA::Field['f:1e3'].~ GFA::Field['f:1000'])
    assert(GFA::Field['f:1e3'].~ 1e3)
    assert(GFA::Field['B:i,123,456'].~ [123, 456.0])

    # Non-commutative
    assert(GFA::Field['i:123'].~ GFA::Field['f:123.4'])
    assert(GFA::Field['f:123.4'] !~ GFA::Field['i:123'])
  end
end
