require 'test_helper'

class Kind::KindTest < Minitest::Test
  require 'kind/basic'

  class MyArray < Array
  end

  def test_Kind_is?
    # FACT: Can check if the given value is the class or a subclass of the expected kind
    assert Kind.is?(Class, Array)
    assert Kind.is?(Array, Array)
    assert Kind.is?(Array, MyArray)
    refute Kind.is?(Module, Array)

    # FACT: Can check if the given value extend or include the expected module
    assert Kind.is?(Enumerable, Enumerable)
    assert Kind.is?(Enumerable, Array)
    assert Kind.is?(Module, Enumerable)
    refute Kind.is?(Class, Enumerable)

    # FACT: Raises an exception if the kind isn't a class or module
    assert_raises_with_message(
      Kind::Error,
      '"1" expected to be a kind of Module/Class'
    ) { Kind.is?('1', String) }

    # FACT: Raises an exception if the value isn't a class or module
    assert_raises_with_message(
      Kind::Error,
      '"2" expected to be a kind of Module/Class'
    ) { Kind.is?(String, '2') }
  end

  def test_Kind_is
    # FACT: Can check if the given value is the class or a subclass of the expected kind
    assert Kind.is(Class, Array)
    assert Kind.is(Array, Array)
    assert Kind.is(Array, MyArray)
    refute Kind.is(Module, Array)

    # FACT: Can check if the given value extend or include the expected module
    assert Kind.is(Enumerable, Enumerable)
    assert Kind.is(Enumerable, Array)
    assert Kind.is(Module, Enumerable)
    refute Kind.is(Class, Enumerable)

    # FACT: Raises an exception if the kind isn't a class or module
    assert_raises_with_message(
      Kind::Error,
      '"1" expected to be a kind of Module/Class'
    ) { Kind.is('1', String) }

    # FACT: Raises an exception if the value isn't a class or module
    assert_raises_with_message(
      Kind::Error,
      '"2" expected to be a kind of Module/Class'
    ) { Kind.is(String, '2') }
  end

  def test_Kind_is!
    assert Array == Kind.is!(Class, Array)
    assert Array == Kind.is!(Array, Array)

    assert Array == Kind.is!(Enumerable, Array)
    assert Enumerable == Kind.is!(Enumerable, Enumerable)
    assert Enumerable == Kind.is!(Module, Enumerable)

    assert_raises_with_message(
      Kind::Error,
      'Enumerable expected to be a Class'
    ) { Kind.is!(Class, Enumerable) }

    assert_raises_with_message(
      Kind::Error,
      'Foo#bar: Enumerable expected to be a Class'
    ) { Kind.is!(Class, Enumerable, label: 'Foo#bar') }
  end

  def test_Kind_of
    assert_equal([], Kind.of(Array, []))
    assert_equal({}, Kind.of(Enumerable, {}))

    assert_raises_with_message(
      Kind::Error,
      'nil expected to be a kind of Array'
    ) { Kind.of(Array, nil) }

    assert_raises_with_message(
      Kind::Error,
      'Foo#bar: nil expected to be a kind of Array'
    ) { Kind.of(Array, nil, label: 'Foo#bar') }
  end

  def test_Kind_of!
    assert_equal([], Kind.of!(Array, []))
    assert_equal({}, Kind.of!(Enumerable, {}))

    assert_raises_with_message(
      Kind::Error,
      'nil expected to be a kind of Array'
    ) { Kind.of!(Array, nil) }

    assert_raises_with_message(
      Kind::Error,
      'Foo#bar: nil expected to be a kind of Array'
    ) { Kind.of!(Array, nil, label: 'Foo#bar') }
  end

  def test_Kind_of?
    # FACT: Can check one instance
    assert Kind.of?(Array, [])
    refute Kind.of?(Array, nil)

    # FACT: Can check multiple instances
    assert Kind.of?(Enumerable, [], {})
    assert Kind.of?(Hash, {}, {})
    refute Kind.of?(Array, [], nil)

    # FACT: Returns a lambda that knows how to check instances when it only receives the kind.
    is_string = Kind.of?(String)

    assert_instance_of(Proc, is_string)
    assert_predicate(is_string, :lambda?)

    assert is_string.call('1')
    refute is_string.call(nil)
  end

  def test_Kind_respond_to?
    assert Kind.respond_to?({}, :[])
    assert Kind.respond_to?({}, :[], :fetch)
    refute Kind.respond_to?({}, :[], :fetch, :foo)
    refute Kind.respond_to?('', :fetch)

    # --

    assert Kind.respond_to?(:is)
    assert Kind.respond_to?(:is?)
    refute Kind.respond_to?(:foo)
  end

  def test_Kind_of_class?
    # FACT: Can check if the given value is a class
    assert Kind.of_class?(Array)

    refute Kind.of_class?(Enumerable)
    refute Kind.of_class?(nil)
    refute Kind.of_class?(1)
  end

  def test_Kind_of_module?
    # FACT: Can check if the given value is a module
    assert Kind.of_module?(Enumerable)

    refute Kind.of_module?(String)
    refute Kind.of_module?(nil)
    refute Kind.of_module?(1)
  end

  def test_Kind_respond_to
    assert_equal('', Kind.respond_to('', :upcase))
    assert_equal('', Kind.respond_to('', :upcase, :strip))

    # -

    assert_raises_with_message(
      Kind::Error,
      'expected 1 to respond to :upcase'
    ) { Kind.respond_to(1, :upcase) }

    assert_raises_with_message(
      Kind::Error,
      'expected 2 to respond to :upcase'
    ) { Kind.respond_to(2, :to_s, :upcase) }
  end

  def test_Kind_respond_to!
    assert_equal('', Kind.respond_to!('', :upcase))
    assert_equal('', Kind.respond_to!('', :upcase, :strip))

    # -

    assert_raises_with_message(
      Kind::Error,
      'expected 1 to respond to :upcase'
    ) { Kind.respond_to!(1, :upcase) }

    assert_raises_with_message(
      Kind::Error,
      'expected 2 to respond to :upcase'
    ) { Kind.respond_to!(2, :to_s, :upcase) }
  end

  def test_Kind_of_module_or_class
    # FACT: Returns the given value if it is a class or module
    assert_equal(Class, Kind.of_module_or_class(Class))
    assert_equal(Array, Kind.of_module_or_class(Array))
    assert_equal(Module, Kind.of_module_or_class(Module))
    assert_equal(Enumerable, Kind.of_module_or_class(Enumerable))

    # FACT: Raises an exception if the kind isn't a class or module
    assert_raises_with_message(
      Kind::Error,
      '"1" expected to be a kind of Module/Class'
    ) { Kind.of_module_or_class('1') }
  end

  def test_Kind_value
    assert '1' == Kind.value(String, '1', default: '')

    assert '' == Kind.value(String, 1, default: '')

    # FACT: The default value must be of the expected kind.
    assert_raises_with_message(
      Kind::Error,
      '2 expected to be a kind of String'
    ) { Kind.value(String, 1, default: 2) }
  end

  def test_Kind_or_nil
    assert_nil(Kind.or_nil(String, 1))

    assert_equal('', Kind.or_nil(String, ''))

    # --

    filled_string = ->(value) { value.is_a?(String) && !value.empty? }

    assert_nil(Kind.or_nil(filled_string, 1))
    assert_nil(Kind.or_nil(filled_string, ''))

    assert_equal('1', Kind.or_nil(filled_string, '1'))
  end

  def test_Kind_in!
    assert 'a' == Kind.in!(['a', :b], 'a')

    assert :b == Kind.in!(['a', :b], :b)

    # FACT: The default value must be of the expected kind.
    assert_raises_with_message(
      Kind::Error,
      '1 expected to be included in ["a", :b]'
    ) { Kind.in!(['a', :b], 1) }
  end

  def test_Kind_include!
    assert 'a' == Kind.include!('a', ['a', :b])

    assert :b == Kind.include!(:b, ['a', :b])

    # FACT: The default value must be of the expected kind.
    assert_raises_with_message(
      Kind::Error,
      '1 expected to be included in ["a", :b]'
    ) { Kind.include!(1, ['a', :b]) }
  end

  def test_Kind_assert_hash!
    assert_raises_with_message(
      ArgumentError,
      ':keys or :schema is missing'
    ) { Kind.assert_hash!({}, some: :arg) }

    assert_raises_with_message(
      ArgumentError,
      "hash can't be empty"
    ) { Kind.assert_hash!({}, keys: :arg) }

    assert_raises_with_message(
      ArgumentError,
      "hash can't be empty"
    ) { Kind.assert_hash!({}, schema: {}) }
  end

  def test_Kind_assert_hash_keys___require_all_false
    h1 = {a: 1, b: 1}
    h2 = {'a' => 1, 'b' => 2}

    # --

    assert_equal(h1, Kind.assert_hash!(h1, keys: [:a, :b]))
    assert_equal(h1, Kind.assert_hash!(h1, keys: [:a, :b, :c]))

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: :b. Valid keys are: :a'
    ) { Kind.assert_hash!(h1, keys: [:a]) }

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: :a. Valid keys are: :b'
    ) { Kind.assert_hash!(h1, keys: :b) }

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: "a". Valid keys are: :a, :b'
    ) { Kind.assert_hash!(h2, keys: [:a, :b]) }

    # --

    assert_equal(h2, Kind.assert_hash!(h2, keys: ['a', 'b']))
    assert_equal(h2, Kind.assert_hash!(h2, keys: ['a', 'b', 'c']))

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: "a". Valid keys are: "b"'
    ) { Kind.assert_hash!(h2, keys: ['b']) }

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: "b". Valid keys are: "a"'
    ) { Kind.assert_hash!(h2, keys: 'a') }

    assert_raises_with_message(
      ArgumentError,
      'Unknown key: :a. Valid keys are: "a", "b"'
    ) { Kind.assert_hash!(h1, keys: ['a', 'b']) }
  end

  def test_Kind_assert_hash_keys___require_all_true
    h1 = {a: 1, b: 1}
    h2 = {'a' => 1, 'b' => 2}

    # --

    assert_equal(h1, Kind.assert_hash!(h1, keys: [:a, :b], require_all: true))

    assert_raises_with_message(
      KeyError,
      "#{h1.inspect} expected to have these keys: [:c]"
    ) { Kind.assert_hash!(h1, keys: [:a, :b, :c], require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h1.inspect} expected to NOT have these keys: [:b]"
    ) { Kind.assert_hash!(h1, keys: [:a], require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h1.inspect} expected to NOT have these keys: [:a]"
    ) { Kind.assert_hash!(h1, keys: :b, require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h2.inspect} expected to have these keys: [:a, :b]"
    ) { Kind.assert_hash!(h2, keys: [:a, :b], require_all: true) }

    # --

    assert_equal(h2, Kind.assert_hash!(h2, keys: ['a', 'b'], require_all: true))

    assert_raises_with_message(
      KeyError,
      "#{h2.inspect} expected to have these keys: [\"c\"]"
    ) { Kind.assert_hash!(h2, keys: ['a', 'b', 'c'], require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h2.inspect} expected to NOT have these keys: [\"a\"]"
    ) { Kind.assert_hash!(h2, keys: ['b'], require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h2.inspect} expected to NOT have these keys: [\"b\"]"
    ) { Kind.assert_hash!(h2, keys: 'a', require_all: true) }

    assert_raises_with_message(
      KeyError,
      "#{h1.inspect} expected to have these keys: [\"a\", \"b\"]"
    ) { Kind.assert_hash!(h1, keys: ['a', 'b'], require_all: true) }
  end

  def test_Kind_assert_schema___require_all_false
    h1 = {hash: {}, array: [], number: 1, string: 'foo', email: 'bar@bar.com', null: nil}

    # --

    assert_equal(h1, Kind.assert_hash!(h1, schema: {
      hash: {},
      array: [],
      email: 'bar@bar.com',
      string: 'foo',
      number: 1,
      null: nil
    }))

    assert_equal(h1, Kind.assert_hash!(h1, schema: {
      hash: Enumerable,
      array: Enumerable,
      email: /\A.+@.+\..+\z/,
      string: String
    }))

    assert_equal(h1, Kind.assert_hash!(h1, schema: {
      hash: Hash,
      array: Array,
      email: String,
      string: String
    }))

    assert_equal(h1, Kind.assert_hash!(h1, schema: {
      email: ->(value) { value.is_a?(String) && value.include?('@') }
    }))

    # # --

    assert_raises_with_message(
      Kind::Error,
      'The key :email has an invalid value'
    ) do
      Kind.assert_hash!(h1, schema: {email: ->(value) { !value.is_a?(String) }})
    end

    assert_raises_with_message(
      Kind::Error,
      'The key :email has an invalid value. Expected: /\\s.*\\s/'
    ) { Kind.assert_hash!(h1, schema: {email: /\s.*\s/ }) }

    assert_raises_with_message(
      Kind::Error,
      'The key :email has an invalid value. Expected: Numeric'
    ) { Kind.assert_hash!(h1, schema: {email: Numeric}) }

    assert_raises_with_message(
      Kind::Error,
      'The key :email has an invalid value. Expected: "foo@foo.com", Given: "bar@bar.com"'
    ) { Kind.assert_hash!(h1, schema: {email: 'foo@foo.com'}) }

    assert_raises_with_message(
      Kind::Error,
      'The key :email has an invalid value. Expected: nil'
    ) { Kind.assert_hash!(h1, schema: {email: nil}) }
  end

  def test_Kind_assert_schema___require_all_true
    h1 = {email: '', number: 1}

    # --

    assert_raises_with_message(
      KeyError,
      "#{h1.inspect} expected to NOT have these keys: [:number]"
    ) { Kind.assert_hash!(h1, require_all: true, schema: {email: String}) }

    # --

    assert_equal(h1, Kind.assert_hash!(h1, require_all: true, schema: {email: String, number: Numeric}))
  end
end
