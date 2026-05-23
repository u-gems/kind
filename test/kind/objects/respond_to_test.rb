require 'test_helper'

class Kind::RespondToTest < Minitest::Test
  def test_the_constructor
    assert_raises_with_message(
      NoMethodError,
      /private method [`']new['].+Kind::RespondTo/
    ) { Kind::RespondTo.new([:fetch]) }

    assert_raises_with_message(
      Kind::Error,
      '1 expected to be a kind of Symbol'
    ) { Kind::RespondTo[1] }
  end

  RespondToFetch = Kind::RespondTo[:fetch]
  RespondToFetchAndValuesAt = Kind::RespondTo[:fetch, :values_at]

  def test_the_inspect_method
    assert_equal('Kind::RespondTo[:fetch]', RespondToFetch.inspect)
    assert_equal('Kind::RespondTo[:fetch, :values_at]', RespondToFetchAndValuesAt.inspect)

    assert_equal(RespondToFetch.name, RespondToFetch.inspect)
    assert_equal(RespondToFetchAndValuesAt.name, RespondToFetchAndValuesAt.inspect)
  end

  def test_the_method_verification
    assert RespondToFetch === {}
    refute RespondToFetch === ''

    assert RespondToFetchAndValuesAt === {}
    refute RespondToFetchAndValuesAt === 1

    assert RespondToFetch.({})
    refute RespondToFetch.(1)

    assert RespondToFetchAndValuesAt.({})
    refute RespondToFetchAndValuesAt.('')

    assert_equal({}, RespondToFetch[{}])
    assert_equal({}, RespondToFetchAndValuesAt[{}])

    assert_raises_with_message(
      Kind::Error,
      '1 expected to be a kind of Kind::RespondTo[:fetch]'
    ) { RespondToFetch[1] }

    assert_raises_with_message(
      Kind::Error,
      '1 expected to be a kind of Kind::RespondTo[:fetch, :values_at]'
    ) { RespondToFetchAndValuesAt[1] }
  end

  def test_the_union_type_builder
    interface = Kind::RespondTo[:fetch] | Kind::Nil

    assert interface === nil
    assert interface === []
    assert interface === {}

    refute interface === 1
  end
end
