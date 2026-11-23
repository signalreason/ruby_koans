require File.expand_path(File.dirname(__FILE__) + '/neo')

# Data.define creates a small class whose only job is to hold a few
# named values. It saves you from writing the constructor, readers,
# equality and inspection methods yourself.
class AboutData < Neo::Koan

  Point = Data.define(:x, :y)

  def test_data_define_creates_a_new_class
    assert_equal __(Class), Point.class
    assert_equal __(Data), Point.superclass
  end

  def test_data_objects_can_be_created_with_positional_arguments
    point = Point.new(3, 4)
    assert_equal __(3), point.x
    assert_equal __(4), point.y
  end

  def test_data_objects_can_also_be_created_with_keyword_arguments
    point = Point.new(y: 4, x: 3)
    assert_equal __(3), point.x
    assert_equal __(4), point.y
  end

  def test_every_member_is_required
    exception = assert_raise(___(ArgumentError)) do
      Point.new(x: 3)
    end
    assert_match(/#{__("missing keyword")}/, exception.message)
  end

  def test_unknown_members_are_rejected
    exception = assert_raise(___(ArgumentError)) do
      Point.new(x: 3, y: 4, z: 5)
    end
    assert_match(/#{__("unknown keyword")}/, exception.message)
  end

  def test_you_can_ask_for_the_members_and_convert_to_a_hash
    point = Point.new(x: 3, y: 4)
    assert_equal __([:x, :y]), Point.members
    assert_equal __({ x: 3, y: 4 }), point.to_h
  end

  # ------------------------------------------------------------------

  def test_data_objects_are_frozen
    point = Point.new(x: 3, y: 4)
    assert_equal __(true), point.frozen?
    assert_equal __(false), point.respond_to?(:x=)
  end

  def test_with_returns_a_changed_copy
    point = Point.new(x: 3, y: 4)
    moved = point.with(y: 10)

    assert_equal __(10), moved.y
    assert_equal __(4), point.y
  end

  # ------------------------------------------------------------------

  def test_data_objects_with_the_same_values_are_equal
    a = Point.new(x: 3, y: 4)
    b = Point.new(x: 3, y: 4)

    assert_equal __(true), a == b
    assert_equal __(false), a.equal?(b)
  end

  def test_data_objects_make_good_hash_keys
    names = { Point.new(x: 0, y: 0) => "origin" }
    assert_equal __("origin"), names[Point.new(x: 0, y: 0)]
  end

  # ------------------------------------------------------------------

  Money = Data.define(:amount, :currency) do
    def initialize(amount:, currency: "USD")
      super
    end

    def to_s
      "#{amount} #{currency}"
    end
  end

  def test_you_can_add_methods_in_a_block
    assert_equal __("5 EUR"), Money.new(5, "EUR").to_s
  end

  def test_you_can_give_members_defaults_by_overriding_initialize
    assert_equal __("USD"), Money.new(amount: 5).currency
    assert_equal __("USD"), Money.new(5).currency
  end

  # THINK ABOUT IT:
  #
  # Ruby also has Struct, which looks a lot like Data but makes objects
  # whose values can be changed. When would you choose one over the
  # other?
end
