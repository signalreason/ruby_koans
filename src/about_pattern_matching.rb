require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutPatternMatching < Neo::Koan

  def test_pattern_may_not_match
    begin
      case [true, false]
      in [a, b] if a == b # The condition after pattern is called guard.
        :match
      end
    rescue Exception => ex
      # What exception has been caught?
      assert_equal __(NoMatchingPatternError), ex.class
    end
  end

  def test_we_can_use_else
    result = case [true, false]
    in [a, b] if a == b
      :match
    else
     :no_match
    end

    assert_equal __(:no_match), result
  end

  # ------------------------------------------------------------------

  def value_pattern(variable)
    case variable
    in 0
      :match_exact_value
    in 1..10
      :match_in_range
    in Integer
      :match_with_class
    else
      :no_match
    end
  end

  def test_value_pattern
    assert_equal __(:match_exact_value), value_pattern(0)
    assert_equal __(:match_in_range), value_pattern(5)
    assert_equal __(:match_with_class), value_pattern(100)
    assert_equal __(:no_match), value_pattern('Not a Number!')
  end

  # ------------------------------------------------------------------
  # This pattern will bind variable to the value

  def variable_pattern_with_binding(variable)
    case 0
    in variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_binding
    assert_equal __(0), variable_pattern_with_binding(1)
  end

  # ------------------------------------------------------------------

  # We can pin the value of the variable with ^

  def variable_pattern_with_pin(variable)
    case 0
    in ^variable
      variable
    else
      :no_match
    end
  end

  def test_variable_pattern_with_pin
    assert_equal __(:no_match), variable_pattern_with_pin(1)
  end

  # ------------------------------------------------------------------

  # We can drop values from pattern

  def pattern_with_dropping(variable)
    case variable
    in [_, 2]
      :match
    else
      :no_match
    end
  end

  def test_pattern_with_dropping
    assert_equal __(:match), pattern_with_dropping(['I will not be checked', 2])
    assert_equal __(:no_match), pattern_with_dropping(['I will not be checked', 'But I will!'])
  end

  # ------------------------------------------------------------------

  # We can use logical *or* in patterns

  def alternative_pattern(variable)
    case variable
    in 0 | false | nil
      :match
    else
      :no_match
    end
  end

  def test_alternative_pattern
    assert_equal __(:match), alternative_pattern(0)
    assert_equal __(:match), alternative_pattern(false)
    assert_equal __(:match), alternative_pattern(nil)
    assert_equal __(:no_match), alternative_pattern(4)
  end

  # ------------------------------------------------------------------

  # As pattern binds the variable to the value if pattern matches
  # pat: pat => var

  def as_pattern
    a = 'First I was afraid'

    case 'I was petrified'
    in String => a
      a
    else
      :no_match
    end
  end

  def test_as_pattern
    assert_equal __('I was petrified'), as_pattern
  end

  # ------------------------------------------------------------------

  # Array pattern works with all objects that have #deconstruct method that returns Array
  # It is useful to cut needed parts from Array-ish objects

  class Deconstructible
    def initialize(str)
      @data = str
    end

    def deconstruct
      @data&.split('')
    end
  end

  def array_pattern(deconstructible)
    case deconstructible
    in 'a', *res, 'd'
      res
    else
      :no_match
    end
  end

  def test_array_pattern
    assert_equal __(['b', 'c']), array_pattern(Deconstructible.new('abcd'))
    assert_equal __(:no_match), array_pattern(Deconstructible.new('123'))
  end

  # ------------------------------------------------------------------

  # Hash pattern is quite the same as Array pattern, but it expects #deconstruct_keys(keys) method
  # It works with symbol keys for now

  class LetterAccountant
    def initialize(str)
      @data = str
    end

    def deconstruct_keys(keys)
      # we will count number of occurrences of each key in our data
      keys.map { |key| [key, @data.count(key.to_s)] }.to_h
    end
  end

  def hash_pattern(deconstructible_as_hash)
    case deconstructible_as_hash
    in {a: a, b: b}
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern
    assert_equal __([3, 2]), hash_pattern(LetterAccountant.new('aaabbc'))
    assert_equal __([0, 0]), hash_pattern(LetterAccountant.new('xyz'))
  end

  # we can write it even shorter
  def hash_pattern_with_sugar(deconstructible_as_hash)
    case deconstructible_as_hash
    in a:, b:
      [a, b]
    else
      :no_match
    end
  end

  def test_hash_pattern_with_sugar
    assert_equal __([3, 2]), hash_pattern_with_sugar(LetterAccountant.new('aaabbc'))
    assert_equal __([0, 0]), hash_pattern_with_sugar(LetterAccountant.new('xyz'))
  end

  # ------------------------------------------------------------------

  # A class name in a pattern matches any object of that class
  def describe(value)
    case value
    in Integer | Float
      :number
    in String
      :string
    in []
      :empty_array
    in Array
      :array
    else
      :something_else
    end
  end

  def test_class_pattern
    assert_equal __(:number), describe(42)
    assert_equal __(:number), describe(4.2)
    assert_equal __(:string), describe("42")
    assert_equal __(:empty_array), describe([])
    assert_equal __(:array), describe([42])
    assert_equal __(:something_else), describe(nil)
  end

  # ------------------------------------------------------------------

  def test_array_pattern_can_collect_the_rest_with_a_splat
    case [1, 2, 3, 4]
    in [first, *rest]
      assert_equal __(1), first
      assert_equal __([2, 3, 4]), rest
    end
  end

  # The find pattern looks for a match anywhere inside an array
  def test_find_pattern
    case [1, "two", :three, 4.0]
    in [*before, Symbol => found, *after]
      assert_equal __(:three), found
      assert_equal __([1, "two"]), before
      assert_equal __([4.0]), after
    end
  end

  # ------------------------------------------------------------------

  def test_hash_pattern_matches_even_when_there_are_extra_keys
    config = { name: "koans", version: 4, debug: true }

    case config
    in { name: String => name, **rest }
      assert_equal __("koans"), name
      assert_equal __({ version: 4, debug: true }), rest
    end
  end

  def test_star_star_nil_means_no_other_keys_are_allowed
    config = { name: "koans", version: 4 }

    result = case config
    in { name: String, **nil }
      :only_a_name
    in { name: String }
      :a_name_and_more
    end

    assert_equal __(:a_name_and_more), result
  end

  # ------------------------------------------------------------------

  # Data objects work with both array and hash patterns
  Point = Data.define(:x, :y)

  def where_is(point)
    case point
    in Point[x: 0, y: 0]
      "at the origin"
    in Point[x: 0, y:]
      "on the y axis at #{y}"
    in Point[x, y]
      "at #{x}, #{y}"
    end
  end

  def test_data_objects_can_be_matched
    assert_equal __("at the origin"), where_is(Point.new(0, 0))
    assert_equal __("on the y axis at 5"), where_is(Point.new(0, 5))
    assert_equal __("at 3, 4"), where_is(Point.new(3, 4))
  end

  # ------------------------------------------------------------------

  # Patterns can also be used on one line, without case
  def test_arrow_pulls_values_out_or_raises_an_error
    point = { x: 1, y: 2 }
    point => { x:, y: }

    assert_equal __(1), x
    assert_equal __(2), y

    assert_raise(___(NoMatchingPatternKeyError)) do
      point => { z: Integer }
    end
  end

  def test_in_checks_whether_a_value_matches
    point = { x: 1, y: 2 }

    assert_equal __(true), (point in { x: Integer })
    assert_equal __(false), (point in { x: String })
    assert_equal __(false), (point in { z: Integer })

    # THINK ABOUT IT:
    #
    # When would you reach for a one-line "=>" or "in" instead of a
    # full case statement?
  end

end
