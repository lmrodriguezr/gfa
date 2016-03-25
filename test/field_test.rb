require "test_helper"

class FieldTest < Test::Unit::TestCase

  def test_char
    f = GFA::Field::Char.new("%")
    assert_equal("%", f.value)
    assert_raise do
      GFA::Field::Char.new(" ")
    end
    assert_raise do
      GFA::Field::Char.new("")
    end
    assert_raise do
      GFA::Field::Char.new("^.^")
    end
  end

  def test_sigint
  end

  def test_float
    f = GFA::Field::Float.new("1.3e-5")
    assert_equal(1.3e-5, f.value)
    assert_raise do
       GFA::Field::Float.new("e-5")
    end
  end

  def test_string
  end

  def test_hex
     f = GFA::Field::Hex.new("C3F0")
     assert_equal("C3F0", f.value)
     assert_raise do
       GFA::Field::Hex.new("C3PO")
     end
  end

  def test_numarray
    f = GFA::Field::NumArray.new("i,1,2,3")
    assert_equal(%w[1 2 3], f.array)
    assert_equal("i", f.modifier)
    assert_raise do
      GFA::Field::NumArray.new("c,1,e,3")
    end
  end

end
