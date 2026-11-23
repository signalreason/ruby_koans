require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutBlocks < Neo::Koan
  def method_with_block
    result = yield
    result
  end

  def test_methods_can_take_blocks
    yielded_result = method_with_block { 1 + 2 }
    assert_equal __(3), yielded_result
  end

  def test_blocks_can_be_defined_with_do_end_too
    yielded_result = method_with_block do 1 + 2 end
    assert_equal __(3), yielded_result
  end

  # ------------------------------------------------------------------

  def method_with_block_arguments
    yield("Jim")
  end

  def test_blocks_can_take_arguments
    method_with_block_arguments do |argument|
      assert_equal __("Jim"), argument
    end
  end

  # ------------------------------------------------------------------

  def many_yields
    yield(:peanut)
    yield(:butter)
    yield(:and)
    yield(:jelly)
  end

  def test_methods_can_call_yield_many_times
    result = []
    many_yields { |item| result << item }
    assert_equal __([:peanut, :butter, :and, :jelly]), result
  end

  # ------------------------------------------------------------------

  def yield_tester
    if block_given?
      yield
    else
      :no_block
    end
  end

  def test_methods_can_see_if_they_have_been_called_with_a_block
    assert_equal __(:with_block), yield_tester { :with_block }
    assert_equal __(:no_block), yield_tester
  end

  # ------------------------------------------------------------------

  def test_block_can_affect_variables_in_the_code_where_they_are_created
    value = :initial_value
    method_with_block { value = :modified_in_a_block }
    assert_equal __(:modified_in_a_block), value
  end

  def test_blocks_can_be_assigned_to_variables_and_called_explicitly
    add_one = lambda { |n| n + 1 }
    assert_equal __(11), add_one.call(10)

    # Alternative calling syntax
    assert_equal __(11), add_one[10]
  end

  def test_stand_alone_blocks_can_be_passed_to_methods_expecting_blocks
    make_upper = lambda { |n| n.upcase }
    result = method_with_block_arguments(&make_upper)
    assert_equal __("JIM"), result
  end

  # ------------------------------------------------------------------

  def method_with_explicit_block(&block)
    block.call(10)
  end

  def test_methods_can_take_an_explicit_block_argument
    assert_equal __(20), method_with_explicit_block { |n| n * 2 }

    add_one = lambda { |n| n + 1 }
    assert_equal __(11), method_with_explicit_block(&add_one)
  end

  # ------------------------------------------------------------------

  def test_blocks_can_use_numbered_parameters_instead_of_names
    assert_equal __([10, 20, 30]), [1, 2, 3].map { _1 * 10 }
    assert_equal __(["a=1", "b=2"]), { a: 1, b: 2 }.map { "#{_1}=#{_2}" }
  end

  def test_using_only_1_does_not_split_up_arrays
    pairs = [[1, 2], [3, 4]]
    assert_equal __([[1, 2], [3, 4]]), pairs.map { _1 }
    assert_equal __([3, 7]), pairs.map { _1 + _2 }
  end

  if ruby_version_at_least?("3.4")
    def test_it_names_the_only_block_parameter
      assert_equal __(["APPLE", "KIWI"]), ["apple", "kiwi"].map { it.upcase }
      assert_equal __([[1, 2], [3, 4]]), [[1, 2], [3, 4]].map { it }
    end
  end

  # (NOTE: We use eval below because the code in the string is not
  # valid Ruby.)
  def test_numbered_parameters_cannot_be_mixed_with_named_ones
    assert_raise(___(SyntaxError)) do
      eval("[1, 2].map { |n| n + _1 }")
    end

    # THINK ABOUT IT:
    #
    # When is { |word| word.upcase } clearer than { it.upcase }?
    # When is it the other way around?
  end

end
