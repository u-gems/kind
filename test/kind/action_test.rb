require 'test_helper'

class KindActionTest < Minitest::Test
  require 'kind/action'

  class User
    attr_reader :id, :name

    def self.find_by(id:)
      new(id, 'John Doe') if id
    end

    def initialize(id, name)
      @id = id
      @name = name
    end

    # def update(params)
    #   !!Kind::Try.presence(params[:name], :strip) { |new_name| @name = new_name }
    # end

    def update(params)
      name = params[:name]

      return false unless name.kind_of?(String)

      name_normalized = name.strip

      return false if name_normalized.empty?

      @name = name_normalized and true
    end

    def errors
      OpenStruct.new(full_messages: ["Name can't be blank"])
    end
  end

  FindUser = ->(arg) do
    input = arg.kind_of?(Hash) ? arg : {}

    user = User.find_by(id: input[:id])

    return Kind::Success(input.merge(user: user)) if user

    Kind::Failure(message: "user not found")
  end

  class UpdateUser
    include Kind::Action

    attribute :user, User

    unless ENV.fetch('KIND_BASIC', '').empty?
      hash_or_nil = ->(value) { value.nil? || value.kind_of?(Hash) }.tap do |kind|
        def kind.name; '(Hash | nil)'; end
      end

      attribute :user_params, hash_or_nil
    else
      attribute :user_params, Kind::Hash | Kind::Nil
    end

    def call!
      return Failure(message: 'user is missing') unless user
      return Failure(message: 'user params is empty') if !user_params || user_params.empty?

      return Success(user: user) if user.update(user_params)

      Failure(message: user.errors.full_messages.join(', '))
    end

    kind_action!
  end

  def test_the_composition_of_find_user_and_update_user_2
    [
      {},
      {id: 1},
      {id: 1, user_params: {}},
      {id: 1, user_params: {name: ''}}
    ].each do |params|
      result =
        FindUser
          .call(params)
          .then(&UpdateUser)

      assert result.failure?
    end

    [
      {id: 1, user_params: {name: 'Rodrigo Serradura'}}
    ].each do |params|
      result =
        FindUser
          .call(params)
          .then(&UpdateUser)

      assert result.success?
    end
  end

  def test_the_execution_of_kind_action_twice
    assert UpdateUser == UpdateUser.kind_action!
  end

  @@contract_error1 =
    begin
      class Foo
        include Kind::Action

        kind_action!
      end
    rescue => e
      e
    end

  @@contract_error2 =
    begin
      class Biz
        include Kind::Action

        def call!
        end

        def foo
        end

        kind_action!
      end
    rescue => e
      e
    end

  @@contract_error3 =
    begin
      class Bar
        include Kind::Action

        def call!(_)
        end

        kind_action!
      end
    rescue => e
      e
    end

  def test_the_contract_errors
    assert Kind::Error === @@contract_error1
    assert_equal('expected KindActionTest::Foo to implement `#call!`', @@contract_error1.message)

    assert Kind::Error === @@contract_error2
    assert_equal('KindActionTest::Biz can only have `#call!` as its public method', @@contract_error2.message)

    assert ArgumentError === @@contract_error3
    assert_equal('KindActionTest::Bar#call! must receive no arguments', @@contract_error3.message)
  end

  @@wrong_usage_error1 =
    begin
      class UpdateUser1 < UpdateUser
      end
    rescue => e
      e
    end

  def test_the_wrong_usage_errors
    assert RuntimeError === @@wrong_usage_error1
    assert_equal("KindActionTest::UpdateUser is a Kind::Action and it can't be inherited", @@wrong_usage_error1.message)
  end

  class Sum
    include Kind::Action

    attribute :a
    attribute :b

    def call!
      Success number: (a || 0) + (b || 0)
    end

    kind_action!
  end

  def test_inspect
    s = Sum.allocate
    s.send(:initialize, {})

    assert_equal("#<KindActionTest::Sum attributes=#{ {a: nil, b: nil}.inspect } nil_attributes=[:a, :b]>", s.inspect)
  end

  class Foo
    include Kind::Action

    def call!
      Failure()
    end

    kind_action!
  end

  def test_failure_receiving_no_args
    r = Foo.({})
    assert r.failure?
    assert_equal(:error, r.type)
    assert_equal({}, r.value)
  end

end
