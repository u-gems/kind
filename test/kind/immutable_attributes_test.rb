require 'test_helper'

class KindImmutableAttributesTest < Minitest::Test
  require 'kind/immutable_attributes'

  class Person1
    include Kind::ImmutableAttributes

    attribute :name
    attribute :age
  end

  def test_the_attributes_without_any_config
    person1 = Person1.new({})

    assert_nil(person1.name)
    assert_nil(person1.age)
    assert_equal({name: nil, age: nil}, person1.attributes)

    assert person1.attribute?(:name)
    assert person1.attribute?(:age)
    refute person1.attribute?(:foo)

    assert person1.nil_attributes == [:name, :age]

    assert person1.nil_attributes?
    assert person1.nil_attributes?(:name)
    assert person1.nil_attributes?(:age)
    assert person1.nil_attributes?(:age, :name)

    assert_nil(person1.attribute(:name))
    assert_nil(person1.attribute(:age))
    assert_nil(person1.attribute(:foo))

    assert_nil(person1.attribute!(:name))
    assert_nil(person1.attribute!(:age))

    assert_raises_with_message(
      KeyError,
      'key not found: :foo'
    ) { person1.attribute!(:foo) }

    person2 = Person1.new(name: :rodrigo)

    assert_equal(:rodrigo, person2.name)
    assert_equal({name: :rodrigo, age: nil}, person2.attributes)

    assert person2.nil_attributes == [:age]
    assert person2.nil_attributes?
    refute person2.nil_attributes?(:name)
    assert person2.nil_attributes?(:age)
    refute person2.nil_attributes?(:age, :name)

    person2b = person2.with_attribute(:age, 34)

    assert_equal(:rodrigo, person2b.name)
    assert_equal(34, person2b.age)
    assert_equal({name: :rodrigo, age: 34}, person2b.attributes)

    assert_equal({name: :rodrigo, age: nil}, person2.attributes)

    person3 = Person1.new(age: '34')

    assert_equal('34', person3.age)
    assert_equal({name: nil, age: '34'}, person3.attributes)

    person3a = person3.with_attribute(:name, 'Serradura')

    assert_equal('Serradura', person3a.name)
    assert_equal('34', person3a.age)
    assert_equal({name: 'Serradura', age: '34'}, person3a.attributes)

    assert_equal({name: nil, age: '34'}, person3.attributes)

    person4 = person3a.with_attributes(name: 'Rodrigo Serradura', age: 'thirty four')

    assert_equal('Rodrigo Serradura', person4.name)
    assert_equal('thirty four', person4.age)
    assert_equal({name: 'Rodrigo Serradura', age: 'thirty four'}, person4.attributes)

    assert_equal({name: 'Serradura', age: '34'}, person3a.attributes)

    assert_equal({name: 'Rodrigo Serradura', age: 'thirty four'}, person4.with_attributes({}).attributes)
  end

  class Person2
    include Kind::ImmutableAttributes

    attribute :name, String
    attribute :age, Numeric
  end

  def test_the_attributes_with_kinds
    person1 = Person2.new({})

    assert_nil(person1.name)
    assert_nil(person1.age)
    assert_equal({name: nil, age: nil}, person1.attributes)

    person2 = Person2.new(name: :rodrigo, age: 34)

    assert_nil(person2.name)
    assert_equal(34, person2.age)
    assert_equal({name: nil, age: 34}, person2.attributes)

    person3 = Person2.new(name: 'Rodrigo', age: '34')

    assert_equal('Rodrigo', person3.name)
    assert_nil(person3.age)
    assert_equal({name: 'Rodrigo', age: nil}, person3.attributes)
  end

  class Person3
    include Kind::ImmutableAttributes

    attribute :name, default: proc(&:to_s)
    attribute :age, default: proc(&:to_i)
  end

  def test_the_attributes_with_defaults_1
    person1 = Person3.new({})

    assert_equal('', person1.name)
    assert_equal(0, person1.age)
    assert_equal({name: '', age: 0}, person1.attributes)

    person2 = Person3.new(name: :rodrigo, age: 34)

    assert_equal('rodrigo', person2.name)
    assert_equal(34, person2.age)
    assert_equal({name: 'rodrigo', age: 34}, person2.attributes)

    person3 = Person3.new(name: 'Rodrigo', age: '34')

    assert_equal('Rodrigo', person3.name)
    assert_equal(34, person3.age)
    assert_equal({name: 'Rodrigo', age: 34}, person3.attributes)

    assert person1.attribute?(:name)
    assert person1.attribute?(:age)

    assert_equal('Rodrigo', person3.attribute(:name))
    assert_equal(34, person3.attribute(:age))

    assert_equal('Rodrigo', person3.attribute!(:name))
    assert_equal(34, person3.attribute!(:age))
  end

  class Person4
    include Kind::ImmutableAttributes

    attribute :name, default: ->(value) { value.to_s }
    attribute :age, default: ->(value) { value.to_i }
  end

  def test_the_attributes_with_defaults_2
    person1 = Person4.new({})

    assert_equal('', person1.name)
    assert_equal(0, person1.age)
    assert_equal({name: '', age: 0}, person1.attributes)

    person2 = Person4.new(name: :rodrigo, age: 34)

    assert_equal('rodrigo', person2.name)
    assert_equal(34, person2.age)
    assert_equal({name: 'rodrigo', age: 34}, person2.attributes)

    person3 = Person4.new(name: 'Rodrigo', age: '34')

    assert_equal('Rodrigo', person3.name)
    assert_equal(34, person3.age)
    assert_equal({name: 'Rodrigo', age: 34}, person3.attributes)
  end

  class Person5
    include Kind::ImmutableAttributes

    attribute :name, String, default: ->(value) { value.to_s.strip }
    attribute :age, Numeric, default: proc(&:to_i)
  end

  def test_the_attributes_with_a_kind_and_defaults
    person1 = Person5.new({})

    assert_equal('', person1.name)
    assert_equal(0, person1.age)
    assert_equal({name: '', age: 0}, person1.attributes)

    person2 = Person5.new(name: :rodrigo, age: 34)

    assert_equal('rodrigo', person2.name)
    assert_equal(34, person2.age)
    assert_equal({name: 'rodrigo', age: 34}, person2.attributes)

    person3 = Person5.new(name: 'Rodrigo', age: '34')

    assert_equal('Rodrigo', person3.name)
    assert_equal(34, person3.age)
    assert_equal({name: 'Rodrigo', age: 34}, person3.attributes)

    person4 = Person5.new(name: '    Rodrigo', age: '34')

    assert_equal('Rodrigo', person4.name)
    assert_equal(34, person4.age)
    assert_equal({name: 'Rodrigo', age: 34}, person4.attributes)
  end

  class User1
    include Kind::ImmutableAttributes

    TrimString = ->(value) { value.to_s.strip }

    attribute :email, String, default: ->(value) { TrimString[value].downcase }
    attribute :password, String, default: TrimString, visibility: :private

    def __password__
      password
    end
  end

  def test_the_attributes_with_a_defined_visibility_1
    user1 = User1.new({})

    assert_equal('', user1.email)
    assert_equal({email: ''}, user1.attributes)

    assert_raises_with_message(
      NoMethodError,
      /private method [`']password['].+KindImmutableAttributesTest::User1/
    ) { user1.password }

    # --

    user2 = User1.new(email: '  Rodrigo.SERRADURA@gmaiL.com', password: '   password   ')

    assert_equal('rodrigo.serradura@gmail.com', user2.email)
    assert_equal({email: 'rodrigo.serradura@gmail.com'}, user2.attributes)

    assert_raises_with_message(
      NoMethodError,
      /private method [`']password['].+KindImmutableAttributesTest::User1/
    ) { user2.password }

    assert_equal('password', user2.__password__)

    assert user2.attribute?(:email)
    assert user2.attribute?(:password)

    assert_equal('rodrigo.serradura@gmail.com', user2.attribute(:email))
    assert_nil(user2.attribute(:password))

    assert_equal('rodrigo.serradura@gmail.com', user2.attribute!(:email))

    assert_raises_with_message(
      KeyError,
      'key not found: :password'
    ) { user2.attribute!(:password) }
  end

  class User2
    include Kind::ImmutableAttributes

    TrimString = ->(value) { value.to_s.strip }

    attribute :email, String, default: ->(value) { TrimString[value].downcase }
    attribute :password, default: TrimString, visibility: :protected

    def __password__
      password
    end
  end

  def test_the_attributes_with_a_defined_visibility_2
    user1 = User2.new({})

    assert_equal('', user1.email)
    assert_equal({email: ''}, user1.attributes)

    assert_raises_with_message(
      NoMethodError,
      /protected method [`']password['].+KindImmutableAttributesTest::User2/
    ) { user1.password }

    # --

    user2 = User2.new(email: '  Rodrigo.SERRADURA@gmaiL.com', password: '   password   ')

    assert_equal('rodrigo.serradura@gmail.com', user2.email)
    assert_equal({email: 'rodrigo.serradura@gmail.com'}, user2.attributes)

    assert_raises_with_message(
      NoMethodError,
      /protected method [`']password['].+KindImmutableAttributesTest::User2/
    ) { user2.password }

    assert_equal('password', user2.__password__)

    assert user2.attribute?(:email)
    assert user2.attribute?(:password)

    assert_equal('rodrigo.serradura@gmail.com', user2.attribute(:email))
    assert_nil(user2.attribute(:password))

    assert_equal('rodrigo.serradura@gmail.com', user2.attribute!(:email))

    assert_raises_with_message(
      KeyError,
      'key not found: :password'
    ) { user2.attribute!(:password) }
  end

  class UserConfigEntity
    include Kind::ImmutableAttributes

    unless ENV.fetch('KIND_BASIC', '').empty?
      attribute :admin, ->(value) { value == true || value == false }
    else
      attribute :admin, Kind::Boolean
    end
  end

  class UserFriendEntity
    include Kind::ImmutableAttributes

    attribute :name, String
  end

  class UserEntity
    include Kind::ImmutableAttributes

    TrimString = ->(value) { value.to_s.strip }

    attribute :name    , String, default: ->(value) { TrimString[value].gsub(/\s+/, ' ') }
    attribute :email   , String, default: ->(value) { TrimString[value].downcase }
    attribute :password, String, default: TrimString, visibility: :protected
    attribute :config  , UserConfigEntity
    attribute :friends , Array(UserFriendEntity)

    def __password__
      password
    end
  end

  def test_the_usage_of_immutable_attributes_as_attribute_kinds
    user_entity = UserEntity.new(
      name: '   Rodrigo   Serradura ',
      email: ' rodrigO.Serradura@GMAIL.cOm',
      password: 'password ',
      config: { admin: true },
      friends: [
        {name: 'Foo'},
        {name: 'Bar'},
      ]
    )

    assert_equal('Rodrigo Serradura', user_entity.name)
    assert_equal('rodrigo.serradura@gmail.com', user_entity.email)

    assert_raises_with_message(
      NoMethodError,
      /protected method [`']password['].+KindImmutableAttributesTest::UserEntity/
    ) { user_entity.password }

    assert_equal('password', user_entity.__password__)

    assert_equal(true, user_entity.config.admin)

    assert_equal('Foo', user_entity.friends[0].name)
    assert_equal('Bar', user_entity.friends[1].name)

    # --

    user_entity2 = UserEntity.new({})

    assert_equal([], user_entity2.nil_attributes)

    assert_equal('', user_entity2.name)
    assert_equal('', user_entity2.email)
    assert_equal('', user_entity2.__password__)
    assert_nil(user_entity2.config.admin)
    assert_equal([], user_entity2.friends)

    # --

    user_entity3 = UserEntity.new(friends: [{}, nil])

    assert_equal([], user_entity3.nil_attributes)

    assert_equal('', user_entity3.name)
    assert_equal('', user_entity3.email)
    assert_equal('', user_entity3.__password__)
    assert_nil(user_entity3.config.admin)
    assert_equal(2, user_entity3.friends.size)
    assert user_entity3.friends[0].nil_attributes?
    assert user_entity3.friends[1].nil_attributes?

    # --

    user_entity4 = UserEntity.new(
      config: UserConfigEntity.new(admin: false),
      friends: [UserFriendEntity.new(name: 'Bla')]
    )

    assert_equal([], user_entity4.nil_attributes)

    assert_equal('', user_entity4.name)
    assert_equal('', user_entity4.email)
    assert_equal('', user_entity4.__password__)
    assert_equal(false, user_entity4.config.admin)
    assert_equal(1, user_entity4.friends.size)
    refute(user_entity4.friends[0].nil_attributes?)
    assert_equal('Bla', user_entity4.friends[0].name)
  end
end
