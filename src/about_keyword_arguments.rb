require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutKeywordArguments < Neo::Koan

  def method_with_keyword_arguments(one: 1, two: 'two')
    [one, two]
  end

  def test_keyword_arguments
    assert_equal __(Array), method_with_keyword_arguments.class
    assert_equal __([1, 'two']), method_with_keyword_arguments
    assert_equal __(['one', 'two']), method_with_keyword_arguments(one: 'one')
    assert_equal __([1, 2]), method_with_keyword_arguments(two: 2)
  end

  def method_with_keyword_arguments_with_mandatory_argument(one, two: 2, three: 3)
    [one, two, three]
  end

  def test_keyword_arguments_with_wrong_number_of_arguments
    exception = assert_raise (___(ArgumentError)) do
      method_with_keyword_arguments_with_mandatory_argument
    end
    assert_match(/#{__("wrong number of arguments")}/, exception.message)
  end

  def method_with_mandatory_keyword_arguments(one:, two: 'two')
    [one, two]
  end

  def test_mandatory_keyword_arguments
    assert_equal __(['one', 'two']), method_with_mandatory_keyword_arguments(one: 'one')
    assert_equal __([1, 2]), method_with_mandatory_keyword_arguments(two: 2, one: 1)
  end

  def test_mandatory_keyword_arguments_without_mandatory_argument
    exception = assert_raise(___(ArgumentError)) do
      method_with_mandatory_keyword_arguments
    end
    assert_match(/#{__("missing keyword: :one")}/, exception.message)
  end

  def test_keyword_arguments_can_also_leave_out_values
    one = "uno"
    assert_equal __(["uno", "two"]), method_with_keyword_arguments(one:)
  end

  # ------------------------------------------------------------------

  def method_that_shows_its_arguments(*args, **kwargs, &block)
    [args, kwargs, block&.call]
  end

  def forward_everything(...)
    method_that_shows_its_arguments(...)
  end

  def test_three_dots_forward_all_arguments_to_another_method
    result = forward_everything(1, 2, color: "red") { :from_the_block }
    assert_equal __([[1, 2], { color: "red" }, :from_the_block]), result
  end

  def forward_all_but_the_first(first, ...)
    method_that_shows_its_arguments(...)
  end

  def test_three_dots_can_come_after_other_parameters
    result = forward_all_but_the_first(:kept_here, 2, color: "blue")
    assert_equal __([[2], { color: "blue" }, nil]), result
  end

  def forward_each_kind_separately(*, **, &)
    method_that_shows_its_arguments(*, **, &)
  end

  def test_unnamed_parameters_can_be_forwarded_one_kind_at_a_time
    result = forward_each_kind_separately(1, size: "large") { :from_the_block }
    assert_equal __([[1], { size: "large" }, :from_the_block]), result

    # THINK ABOUT IT:
    #
    # Why might you forward arguments with ... or *, ** and & instead
    # of listing every parameter by name?
  end

end
