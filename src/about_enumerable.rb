require File.expand_path(File.dirname(__FILE__) + '/neo')

# Arrays, hashes, ranges and many other collections share a large set
# of methods from the Enumerable module. You met a few of them in
# about_iteration. Here are some more that save a lot of hand-written
# loops.
class AboutEnumerable < Neo::Koan

  def test_sum_adds_things_up
    assert_equal __(6), [1, 2, 3].sum
    assert_equal __(10), (1..4).sum
    assert_equal __(14), [1, 2, 3].sum { |n| n * n }
  end

  def test_min_by_max_by_and_sort_by_compare_using_a_block
    words = ["pear", "fig", "banana"]

    assert_equal __("fig"), words.min_by { |word| word.size }
    assert_equal __("banana"), words.max_by { |word| word.size }
    assert_equal __(["fig", "pear", "banana"]), words.sort_by { |word| word.size }
  end

  # ------------------------------------------------------------------

  def test_filter_map_selects_and_transforms_in_one_step
    result = [1, 2, 3, 4].filter_map { |n| n * 10 if n.even? }
    assert_equal __([20, 40]), result
  end

  def test_partition_splits_a_collection_in_two
    evens, odds = (1..6).partition { |n| n.even? }

    assert_equal __([2, 4, 6]), evens
    assert_equal __([1, 3, 5]), odds
  end

  def test_group_by_collects_items_into_a_hash
    words = ["ant", "bee", "wasp", "moth", "fly"]
    result = words.group_by { |word| word.size }

    assert_equal __({ 3 => ["ant", "bee", "fly"], 4 => ["wasp", "moth"] }), result
  end

  def test_tally_counts_how_often_each_item_appears
    votes = ["red", "blue", "red", "green", "red", "blue"]
    assert_equal __({ "red" => 3, "blue" => 2, "green" => 1 }), votes.tally
  end

  # ------------------------------------------------------------------

  def test_each_slice_and_each_cons_work_in_groups
    assert_equal __([[1, 2, 3], [4, 5, 6], [7]]), (1..7).each_slice(3).to_a
    assert_equal __([[1, 2], [2, 3], [3, 4]]), (1..4).each_cons(2).to_a
  end

  def test_zip_pairs_up_items_from_several_collections
    names = ["Ann", "Bob"]
    ages = [31, 42]

    assert_equal __([["Ann", 31], ["Bob", 42]]), names.zip(ages)
    assert_equal __({ "Ann" => 31, "Bob" => 42 }), names.zip(ages).to_h
  end

  def test_with_index_adds_a_counter_to_any_iteration
    result = ["a", "b", "c"].map.with_index(1) { |letter, i| "#{i}#{letter}" }
    assert_equal __(["1a", "2b", "3c"]), result
  end

  def test_each_with_object_builds_up_a_result
    result = ["apple", "avocado", "banana"].each_with_object({}) do |fruit, index|
      (index[fruit[0]] ||= []) << fruit
    end

    assert_equal __({ "a" => ["apple", "avocado"], "b" => ["banana"] }), result
  end

  # ------------------------------------------------------------------

  # Hashes are Enumerable too, but they also have methods of their own,
  # like transform_values and except, that other collections don't.
  def test_hashes_have_handy_transforming_methods
    prices = { apple: 1, pear: 2, fig: 3 }

    assert_equal __({ apple: 2, pear: 4, fig: 6 }), prices.transform_values { |price| price * 2 }
    assert_equal __({ fig: 3 }), prices.select { |fruit, price| price > 2 }
    assert_equal __({ apple: 1 }), prices.except(:pear, :fig)
    assert_equal __(6), prices.sum { |fruit, price| price }
  end

  # ------------------------------------------------------------------

  def test_lazy_lets_you_work_with_endless_collections
    numbers = (1..Float::INFINITY).lazy.map { |n| n * 2 }.select { |n| n % 3 == 0 }

    assert_equal __([6, 12, 18]), numbers.first(3)

    # THINK ABOUT IT:
    #
    # What would happen without the call to lazy?
  end

  # ------------------------------------------------------------------

  # Any class can get the Enumerable methods (like sum, select, sort_by
  # and tally) by defining "each" and including Enumerable. (You will
  # learn more about include in about_modules.)
  class Countdown
    include Enumerable

    def initialize(from)
      @from = from
    end

    def each
      @from.downto(1) { |n| yield n }
    end
  end

  def test_your_own_classes_can_be_enumerable
    countdown = Countdown.new(4)

    assert_equal __([4, 3, 2, 1]), countdown.to_a
    assert_equal __(10), countdown.sum
    assert_equal __([4, 2]), countdown.select { |n| n.even? }
    assert_equal __(true), countdown.include?(3)
  end

end
