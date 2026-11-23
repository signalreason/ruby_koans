require File.expand_path(File.dirname(__FILE__) + '/neo')

# A Set is a collection of unique items with no particular position.
# It is built into Ruby, so you don't need to require anything to use it.
class AboutSets < Neo::Koan

  def test_creating_sets
    assert_equal __(Set), Set.new.class
    assert_equal __(3), Set[1, 2, 3].size
    assert_equal __(true), Set[1, 2, 3] == Set.new([1, 2, 3])
  end

  def test_sets_ignore_duplicates
    set = Set.new([1, 2, 2, 3, 3, 3])
    assert_equal __(3), set.size

    set << 3
    assert_equal __(3), set.size
  end

  def test_order_does_not_matter_when_comparing_sets
    assert_equal __(true), Set[1, 2, 3] == Set[3, 2, 1]
    assert_equal __(false), [1, 2, 3] == [3, 2, 1]
  end

  def test_arrays_can_be_turned_into_sets
    set = ["red", "blue", "red"].to_set
    assert_equal __(Set["red", "blue"]), set
  end

  # ------------------------------------------------------------------

  def test_checking_whether_something_is_in_a_set
    vowels = Set["a", "e", "i", "o", "u"]

    assert_equal __(true), vowels.include?("e")
    assert_equal __(false), vowels.include?("y")

    # THINK ABOUT IT:
    #
    # Arrays have include? too. Why might a set answer this question
    # much faster than an array with thousands of items?
  end

  def test_add_with_a_question_mark_tells_you_if_anything_changed
    set = Set[1, 2]

    assert_equal __(nil), set.add?(2)
    assert_equal __(Set[1, 2, 3]), set.add?(3)
  end

  def test_delete_removes_an_item
    set = Set[1, 2, 3]
    set.delete(2)
    assert_equal __(Set[1, 3]), set
  end

  # ------------------------------------------------------------------

  def test_sets_can_be_combined
    a = Set[1, 2, 3]
    b = Set[3, 4]

    assert_equal __(Set[1, 2, 3, 4]), a | b
    assert_equal __(Set[3]), a & b
    assert_equal __(Set[1, 2]), a - b
    assert_equal __(Set[1, 2, 4]), a ^ b
  end

  def test_sets_can_be_compared_with_each_other
    small = Set[1, 2]
    big = Set[1, 2, 3]

    assert_equal __(true), small.subset?(big)
    assert_equal __(true), big.superset?(small)
    assert_equal __(true), small <= big
    assert_equal __(false), big <= small
    assert_equal __(true), small.intersect?(big)
    assert_equal __(true), small.disjoint?(Set[4, 5])
  end

  # ------------------------------------------------------------------

  def test_sets_are_enumerable_but_map_returns_an_array
    set = Set[1, 2, 3]

    assert_equal __(6), set.sum
    assert_equal __([2, 4, 6]), set.map { |n| n * 2 }.sort
    assert_equal __(Array), set.map { |n| n * 2 }.class
  end

end
