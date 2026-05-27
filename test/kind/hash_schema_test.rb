require 'test_helper'

require 'kind/hash_schema'

class Kind::HashSchemaTest < Minitest::Test
  def test_the_filtering_of_scalar_values_without_a_type
    output1 = Kind::HashSchema.new(:name, :age).filter(name: 'Rodrigo', age: 34, foo: :bar)

    assert_equal([:name, :age], output1.keys)

    assert_equal('Rodrigo', output1[:name])
    assert_equal(34, output1[:age])

    # --

    output2 = Kind::HashSchema.new('name', 'age').filter(name: 'Rodrigo', age: 34, foo: :bar)

    assert_equal({}, output2)

    # --

    output3 = Kind::HashSchema.new('name', 'age').filter('name' => 'Rodrigo', 'age' => 34, 'foo' => :bar)

    assert_equal(['name', 'age'], output3.keys)

    assert_equal('Rodrigo', output3['name'])
    assert_equal(34, output3['age'])
  end

  def test_the_filtering_of_scalar_values_with_a_type
    schema1 = Kind::HashSchema.new(name: String, age: Integer)

    # -

    output1 = schema1.filter(name: 'Rodrigo', age: 34, foo: :bar)

    assert_equal([:name, :age], output1.keys)

    assert_equal('Rodrigo', output1[:name])
    assert_equal(34, output1[:age])

    # -

    output2 = schema1.filter(name: :rodrigo, age: 34, foo: :bar)

    assert_equal([:age], output2.keys)

    assert_equal(34, output2[:age])

    # -

    output3 = schema1.filter(name: 'Rodrigo', age: 34.0, foo: :bar)

    assert_equal([:name], output3.keys)

    assert_equal('Rodrigo', output3[:name])

    # -

    output4 = schema1.filter(name: :rodrigo, age: 34.0, foo: :bar)

    assert_equal({}, output4)
  end

  def test_the_filtering_of_hash_values
    hash = {
      person: {
        age: 5,
        name: 'Bella',
        pets: [
          {name: 'Golden', category: 'fishes'},
          {name: 'Purplish', category: 'dogs'}
        ]
      }
    }

    # --

    [
      Kind::HashSchema.new(:name, :age, pets: []),
      Kind::HashSchema.new(:name, :age, pets: Array)
    ].each do |schema|
      output = Kind::HashSchema.new(:name, :age, pets: Array).filter(hash[:person])

      assert_equal([:name, :age, :pets], output.keys)

      assert_equal(5, output[:age])
      assert_equal('Bella', output[:name])
      assert_equal({name: 'Golden', category: 'fishes'}, output[:pets][0])
      assert_equal({name: 'Purplish', category: 'dogs'}, output[:pets][1])
    end

    # --

    [
      Kind::HashSchema.new(person: [:age, :name, pets: Array]),
      Kind::HashSchema.new(person: [:age, :name, pets: Kind::Array]),
      Kind::HashSchema.new(person: [:age, :name, pets: (Kind::Array | Hash)]),
      Kind::HashSchema.new(person: [:age, :name, pets: ->(value) { value.is_a?(Array) }])
    ].each do |schema|
      output = schema.filter(hash)

      assert_equal([:person], output.keys)

      output_person = output[:person]

      assert_equal([:age, :name, :pets], output_person.keys, schema.spec.inspect)

      assert_equal(5, output_person[:age])
      assert_equal('Bella', output_person[:name])
      assert_equal({name: 'Golden', category: 'fishes'}, output_person[:pets][0])
      assert_equal({name: 'Purplish', category: 'dogs'}, output_person[:pets][1])
    end

    # --

    [
      Kind::HashSchema.new(person: [:age, :name, pets: [Hash]]),
      Kind::HashSchema.new(person: [:age, :name, pets: Array(Hash)]),
      Kind::HashSchema.new(person: [:age, :name, pets: Array(Kind::Hash)]),
      Kind::HashSchema.new(person: [:age, :name, pets: Array(Kind::Hash | Array)]),
      Kind::HashSchema.new(person: [:age, :name, pets: Array(->(value) { value.is_a?(Hash) })])
    ].each do |schema|
      output = schema.filter(hash)

      assert_equal([:person], output.keys)

      output_person = output[:person]

      assert_equal([:age, :name, :pets], output_person.keys)

      assert_equal(5, output_person[:age])
      assert_equal('Bella', output_person[:name])
      assert_equal({name: 'Golden', category: 'fishes'}, output_person[:pets][0])
      assert_equal({name: 'Purplish', category: 'dogs'}, output_person[:pets][1])
    end

    [
      Kind::HashSchema.new(person: [:age, :name, pets: []]),
      Kind::HashSchema.new(person: [:age, :name, pets: [String]]),
      Kind::HashSchema.new(person: [:age, :name, pets: Array(String)])
    ].each do |schema|
      output = schema.filter(hash)

      assert_equal([:person], output.keys)

      output_person = output[:person]

      assert_equal([:age, :name, :pets], output_person.keys)

      assert_equal(5, output_person[:age])
      assert_equal('Bella', output_person[:name])
      assert_equal([], output_person[:pets])
    end
  end

  def assert_filtered_out(hash, key)
    refute(hash.has_key?(key), "key #{key.inspect} has not been filtered out")
  end

  def test_nested_keys_filtering
    params = {
      book: {
        title: "Romeo and Juliet",
        authors: [
          { name: "William Shakespeare", born: "1564-04-26" },
          { name: "Christopher Marlowe" },
          { name: %w(malicious injected names) }
        ],
        details: { pages: 200, genre: "Tragedy" },
        id: { isbn: "x" }
      },
      magazine: "Mjallo!"
    }

    schema1 = Kind::HashSchema.new(book: [ :title, { authors: [ :name ] }, { details: :pages }, :id ])

    filtered1 = schema1.filter(params)

    assert_equal "Romeo and Juliet", filtered1[:book][:title]

    assert_equal "William Shakespeare", filtered1[:book][:authors][0][:name]
    assert_equal "Christopher Marlowe", filtered1[:book][:authors][1][:name]
    assert_equal 200, filtered1[:book][:details][:pages]

    assert_filtered_out filtered1, :magazine
    assert_filtered_out filtered1[:book], :id
    assert_filtered_out filtered1[:book][:details], :genre
    assert_filtered_out filtered1[:book][:authors][0], :born
    assert_filtered_out filtered1[:book][:authors][2], :name

    # --

    schema2 = Kind::HashSchema.new(book: [ :title, { authors: [ name: Array ] }, { details: :pages }, :id ])

    filtered2 = schema2.filter(params)

    assert_equal "Romeo and Juliet", filtered2[:book][:title]

    assert_predicate filtered2[:book][:authors][0], :empty?
    assert_predicate filtered2[:book][:authors][1], :empty?
    assert_equal %w(malicious injected names), filtered2[:book][:authors][2][:name]

    assert_equal 200, filtered2[:book][:details][:pages]

    assert_filtered_out filtered2, :magazine
    assert_filtered_out filtered2[:book], :id
    assert_filtered_out filtered2[:book][:details], :genre
    assert_filtered_out filtered2[:book][:authors][0], :born

    # --

    schema3 = Kind::HashSchema.new(book: [ :title, { authors: [ name: String ] }, { details: {pages: Integer} }, :id ])

    filtered3 = schema3.filter(params)

    assert_equal "Romeo and Juliet", filtered3[:book][:title]

    assert_equal "William Shakespeare", filtered3[:book][:authors][0][:name]
    assert_equal "Christopher Marlowe", filtered3[:book][:authors][1][:name]
    assert_equal 200, filtered3[:book][:details][:pages]

    assert_filtered_out filtered3, :magazine
    assert_filtered_out filtered3[:book], :id
    assert_filtered_out filtered3[:book][:details], :genre
    assert_filtered_out filtered3[:book][:authors][0], :born
    assert_filtered_out filtered3[:book][:authors][2], :name
  end

  def test_the_filtering_of_numeric_keys
    person1 = {
      age: 5,
      name: 'Bella',
      pets: {
        0 => { name: 'Golden', category: 'fishes' },
        1 => {name: 'Purplish', category: 'dogs'}
      }
    }

    person2 = {
      age: 5,
      name: 'Bella',
      pets: {
        '0' => { name: 'Golden', category: 'fishes' },
        '1' => {name: 'Purplish', category: 'dogs'}
      }
    }

    schema = Kind::HashSchema.new(age: Integer, name: String, pets: [name: String])

    # --

    filtered1 = schema.filter(person1)

    assert_equal(5, filtered1[:age])
    assert_equal('Bella', filtered1[:name])

    assert_instance_of(Hash, filtered1[:pets])

    assert_equal({name: 'Golden'}, filtered1[:pets][0])
    assert_equal({name: 'Purplish'}, filtered1[:pets][1])

    # --

    filtered2 = schema.filter(person2)

    assert_equal(5, filtered2[:age])
    assert_equal('Bella', filtered2[:name])

    assert_instance_of(Hash, filtered2[:pets])

    assert_equal({name: 'Golden'}, filtered2[:pets]['0'])
    assert_equal({name: 'Purplish'}, filtered2[:pets]['1'])
  end

  def test_the_filtering_of_scalar_values_in_an_array
    person = {
      age: 5,
      name: 'Bella',
      pets: [ 'Dog', 'Fish', {name: 'Purplish', category: 'dogs'} ]
    }

    filtered = Kind::HashSchema.new(age: Integer, name: String, pets: []).filter(person)

    assert_equal(5, filtered[:age])
    assert_equal('Bella', filtered[:name])
    assert_equal(['Dog', 'Fish'], filtered[:pets])
  end
end
