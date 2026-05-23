<p align="center">
  <h1 align="center" id="-kind">🤷 kind</h1>
  <p align="center"><i>A development toolkit for Ruby with several small/cohesive abstractions to empower your development workflow - It's totally free of dependencies.</i></p>
  <p align="center">
    <a href="https://badge.fury.io/rb/kind"><img src="https://badge.fury.io/rb/kind.svg" alt="Gem Version" height="18"></a>
    <a href="https://github.com/serradura/kind/actions/workflows/ci.yml"><img alt="Build Status" src="https://github.com/serradura/kind/actions/workflows/ci.yml/badge.svg"></a>
    <br/>
    <a href="https://qlty.sh/gh/serradura/projects/kind"><img src="https://qlty.sh/gh/serradura/projects/kind/maintainability.svg" alt="Maintainability" /></a>
    <a href="https://qlty.sh/gh/serradura/projects/kind"><img src="https://qlty.sh/gh/serradura/projects/kind/coverage.svg" alt="Code Coverage" /></a>
    <br/>
    <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
    <img src="https://img.shields.io/badge/Rails%20%3E%3D%206.0%2C%20%3C%3D%20Edge-rails.svg?colorA=444&colorB=333" alt="Rails">
  </p>
</p>

**Motivation:**

This project was born to help me with a simple task, create a light and fast type checker (at runtime) for Ruby. The initial idea was to have something to raise an exception when a method or function (procs) received a wrong input.

But through time it was natural the addition of more features to improve the development workflow, like monads ([`Kind::Maybe`](#kindmaybe), `Kind::Either` / `Kind::Result`),  enums (`Kind::Enum`), immutable objects (`Kind::ImmutableAttributes`), [type validation via ActiveModel::Validation](#kindvalidator-activemodelvalidations), and several abstractions to help the implementation of business logic (`Kind::Functional::Steps`, `Kind::Functional::Action`, `Kind::Action`).

So, I invite you to check out these features to see how they could be useful for you. Enjoy!

## Documentation <!-- omit in toc -->

Version    | Documentation
---------- | -------------
unreleased | https://github.com/serradura/kind/blob/main/README.md
6.0.0      | https://github.com/serradura/kind/blob/v6.x/README.md
5.10.0     | https://github.com/serradura/kind/blob/v5.x/README.md

## Table of Contents <!-- omit in toc -->
- [Compatibility](#compatibility)
- [Installation](#installation)
- [Usage](#usage)
  - [Kind.\<Type\>[]](#kindtype)
  - [Kind::\<Type\>.===()](#kindtype-1)
  - [Kind::\<Type\>.value?()](#kindtypevalue)
  - [Kind::\<Type\>.or_nil()](#kindtypeor_nil)
  - [Kind::\<Type\>.or_undefined()](#kindtypeor_undefined)
  - [Kind::\<Type\>.or()](#kindtypeor)
  - [Kind::\<Type\>.value()](#kindtypevalue-1)
  - [Kind::\<Type\>.maybe](#kindtypemaybe)
  - [Kind::\<Type\>?](#kindtype-2)
  - [Kind::{Array,Hash,String,Set}.empty_or()](#kindarrayhashstringsetempty_or)
  - [List of all type handlers](#list-of-all-type-handlers)
    - [Core](#core)
    - [Stdlib](#stdlib)
    - [Custom](#custom)
  - [Creating type handlers](#creating-type-handlers)
    - [Dynamic creation](#dynamic-creation)
      - [Using a class or a module](#using-a-class-or-a-module)
      - [Using Kind.object(name:, &block)](#using-kindobjectname-block)
    - [Kind::<Type> object](#kindtype-object)
  - [Utility methods](#utility-methods)
    - [Kind.of_class?()](#kindof_class)
    - [Kind.of_module?()](#kindof_module)
    - [Kind.of_module_or_class()](#kindof_module_or_class)
    - [Kind.respond_to()](#kindrespond_to)
    - [Kind.of()](#kindof)
    - [Kind.of?()](#kindof-1)
    - [Kind.value()](#kindvalue)
    - [Kind.is()](#kindis)
  - [Utility modules](#utility-modules)
    - [Kind::Try](#kindtry)
    - [Kind::Dig](#kinddig)
    - [Kind::Presence](#kindpresence)
- [Kind::Undefined](#kindundefined)
- [Kind::Maybe](#kindmaybe)
    - [Replacing blocks by lambdas](#replacing-blocks-by-lambdas)
  - [Kind::Maybe[], Kind::Maybe.wrap() and Kind::Maybe#then method aliases](#kindmaybe-kindmaybewrap-and-kindmaybethen-method-aliases)
    - [Replacing blocks by lambdas](#replacing-blocks-by-lambdas-1)
  - [Kind::None() and Kind::Some()](#kindnone-and-kindsome)
  - [Kind::Optional](#kindoptional)
    - [Replacing blocks by lambdas](#replacing-blocks-by-lambdas-2)
  - [Kind::Maybe(<Type>)](#kindtypemaybe)
    - [Real world examples](#real-world-examples)
  - [Error handling](#error-handling)
    - [Kind::Maybe.wrap {}](#kindmaybewrap-)
    - [Kind::Maybe.map! or Kind::Maybe.then!](#kindmaybemap-or-kindmaybethen)
  - [Kind::Maybe#try](#kindmaybetry)
  - [Kind::Maybe#try!](#kindmaybetry-1)
  - [Kind::Maybe#dig](#kindmaybedig)
  - [Kind::Maybe#check](#kindmaybecheck)
  - [Kind::Maybe#presence](#kindmaybepresence)
- [Kind::Empty](#kindempty)
  - [Defining Empty as Kind::Empty an alias](#defining-empty-as-kindempty-an-alias)
- [Kind::Validator (ActiveModel::Validations)](#kindvalidator-activemodelvalidations)
  - [Usage](#usage-1)
    - [Object#===](#object)
    - [Kind.is](#kindis-1)
    - [Object#instance_of?](#objectinstance_of)
    - [Object#respond_to?](#objectrespond_to)
    - [Array.new.all? { |item| item.kind_of?(Class) }](#arraynewall--item-itemkind_ofclass-)
    - [Array.new.all? { |item| expected_values.include?(item) }](#arraynewall--item-expected_valuesincludeitem-)
  - [Defining the default validation strategy](#defining-the-default-validation-strategy)
  - [Using the `allow_nil` and `strict` options](#using-the-allow_nil-and-strict-options)
- [Similar Projects](#similar-projects)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Compatibility

| kind             | branch | ruby     | activemodel    |
| ---------------- | ------ | -------- | -------------- |
| unreleased       | main   | >= 2.7   | >= 6.0         |
| 6.0.0            | v6.x   | >= 2.7   | >= 6.0         |
| 5.10.0           | v5.x   | >= 2.1.0, <= 3.0.0 | >= 3.2, < 7.0  |

This library is tested (CI matrix) against:

| Ruby / Rails | 6.0 | 6.1 | 7.0 | 7.1 | 7.2 | 8.0 | 8.1 | Edge |
|--------------|-----|-----|-----|-----|-----|-----|-----|------|
| 2.7          | ✅  | ✅  | ✅  | ✅  |     |     |     |      |
| 3.0          | ✅  | ✅  | ✅  | ✅  |     |     |     |      |
| 3.1          |     |     | ✅  | ✅  | ✅  |     |     |      |
| 3.2          |     |     | ✅  | ✅  | ✅  | ✅  |     |      |
| 3.3          |     |     | ✅  | ✅  | ✅  | ✅  | ✅  | ✅   |
| 3.4          |     |     |     |     | ✅  | ✅  | ✅  | ✅   |
| 4.x          |     |     |     |     |     |     | ✅  | ✅   |
| Head         |     |     |     |     |     |     | ✅  | ✅   |

> Note: The activemodel is an optional dependency, it is related with the [Kind::Validator](#kindvalidator-activemodelvalidations).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kind', '~> 6.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install kind

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Usage

With this gem you can add some kind of type checking at runtime. e.g:

```ruby
def sum(a, b)
  Kind::Numeric[a] + Kind::Numeric[b]
end

sum(1, 1)   # 2

sum('1', 1) # Kind::Error ("\"1\" expected to be a kind of Numeric")
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind.\<Type\>[]

By default, basic verifications are strict. So, when you perform `Kind::Hash[value]` the given value will be returned if it was a Hash, but if not, an error will be raised.

```ruby
Kind::Hash[nil]  # Kind::Error (nil expected to be a kind of Hash)
Kind::Hash['']   # Kind::Error ("" expected to be a kind of Hash)
Kind::Hash[a: 1] # {a: 1}
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.===()

Use this method to verify if the given object has the expected type.

```ruby
Kind::Enumerable === {} # true
Kind::Enumerable === '' # false
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.value?()

This method works like `.===`, but the difference is what happens when you invoke it without arguments.

```ruby
# Example of calling `.value?` with an argument:

Kind::Enumerable.value?({}) # true
Kind::Enumerable.value?('') # false
```

When `.value?` is called without an argument, it will return a lambda which will know how to perform the kind verification.

```ruby
collection = [ {number: 1}, 'number 2', {number: 3}, :number_4, [:number, 5] ]

collection.select(&Kind::Enumerable.value?) # [{:number=>1}, {:number=>3}, [:number, 5]]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.or_nil()

But if you don't need a strict type verification, use the `.or_nil` method.

```ruby
Kind::Hash.or_nil('')     # nil
Kind::Hash.or_nil({a: 1}) # {a: 1}
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.or_undefined()

This method works like `.or_nil`, but it will return a [`Kind::Undefined`](#kindundefined) instead of `nil`.

```ruby
Kind::Hash.or_undefined('')     # Kind::Undefined
Kind::Hash.or_undefined({a: 1}) # {a: 1}
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.or()

This method can return a fallback if the given value isn't an instance of the expected kind.

```ruby
Kind::Hash.or({}, [])      # {}
Kind::Hash.or(nil, [])     # nil
Kind::Hash.or(nil, {a: 1}) # {a: 1}
```

If it doesn't receive a second argument (the value), it will return a callable that knows how to expose an instance of the expected type or a fallback if the given value is wrong.

```ruby
collection = [ {number: 1}, 'number 2', {number: 3}, :number_4, [:number, 5] ]

collection.map(&Kind::Hash.or({}))  # [{:number=>1}, {}, {:number=>3}, {}, {}]
collection.map(&Kind::Hash.or(nil)) # [{:number=>1}, nil, {:number=>3}, nil, nil]
```

An error will be raised if the fallback didn't have the expected kind or if not `nil` / `Kind::Undefined`.

```ruby
collection = [ {number: 1}, 'number 2', {number: 3}, :number_4, [:number, 5] ]

collection.map(&Kind::Hash.or(:foo)) # Kind::Error (:foo expected to be a kind of Hash)
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.value()

This method ensures that you will have a value of the expected kind. But, in the case of the given value be invalid, this method will require a default value (with the expected kind) to be returned.
```ruby
Kind::String.value(1, default: '')   # ""

Kind::String.value('1', default: '') # "1"

Kind::String.value('1', default: 1)  # Kind::Error (1 expected to be a kind of String)
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>.maybe

This method exposes a [typed `Kind::Maybe`](#kindtypemaybe) and using it will be possible to apply a sequence of operations in the case of the wrapped value has the expected kind.

```ruby
Double = ->(value) do
  Kind::Numeric.maybe(value)
               .then { |number| number * 2 }
               .value_or(0)
end

Double.('2') # 0
Double.(2)   # 4
```

If it is invoked without arguments, it returns the typed Maybe. But, if it receives arguments, it will behave like the `Kind::Maybe.wrap` method. e.g.

```ruby
Kind::Integer.maybe #<Kind::Maybe::Typed:0x0000... @kind=Kind::Integer>

Kind::Integer.maybe(0).some?               # true
Kind::Integer.maybe { 1 }.some?            # true
Kind::Integer.maybe(2) { |n| n * 2 }.some? # true

Kind::Integer.maybe { 2 / 0 }.none?          # true
Kind::Integer.maybe(2) { |n| n / 0 }.none?   # true
Kind::Integer.maybe('2') { |n| n * n }.none? # true
```

> **Note:** You can use `Kind::\<Type\>.optional` as an alias for `Kind::\<Type\>.maybe`.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::\<Type\>?

There is a second way to do a type verification and know if one or multiple values has the expected type. You can use the predicate kind methods (`Kind::Hash?`). e.g:

```ruby
# Verifying one value
Kind::Enumerable?({}) # true

# Verifying multiple values
Kind::Enumerable?({}, [], Set.new) # true
```

Like the `Kind::<Type>.value?` method, if the `Kind::<Type>?` doesn't receive an argument, it will return a lambda which will know how to perform the kind verification.

```ruby
collection = [ {number: 1}, 'number 2', {number: 3}, :number_4, [:number, 5] ]

collection.select(&Kind::Enumerable?) # [{:number=>1}, {:number=>3}, [:number, 5]]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::{Array,Hash,String,Set}.empty_or()

This method is available for some type handlers (`Kind::Array`, `Kind::Hash`, `Kind::String`, `Kind::Set`), and it will return an empty frozen value if the given one hasn't the expected kind.
```ruby
Kind::Array.empty_or({})         # []
Kind::Array.empty_or({}).frozen? # true
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### List of all type handlers

#### Core

* `Kind::Array`
* `Kind::Class`
* `Kind::Comparable`
* `Kind::Enumerable`
* `Kind::Enumerator`
* `Kind::File`
* `Kind::Float`
* `Kind::Hash`
* `Kind::Integer`
* `Kind::IO`
* `Kind::Method`
* `Kind::Module`
* `Kind::Numeric`
* `Kind::Proc`
* `Kind::Queue`
* `Kind::Range`
* `Kind::Regexp`
* `Kind::String`
* `Kind::Struct`
* `Kind::Symbol`
* `Kind::Time`

#### Stdlib

* `Kind::OpenStruct`
* `Kind::Set`

#### Custom

* `Kind::Boolean`
* `Kind::Callable`
* `Kind::Lambda`

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Creating type handlers

There are two ways to do this, you can create type handlers dynamically or defining a module.

#### Dynamic creation

##### Using a class or a module

```ruby
class User
end

user = User.new

kind_of_user = Kind[User]

# kind_of_user.name
# kind_of_user.kind
# The type handler can return its kind and its name
kind_of_user.name # "User"
kind_of_user.kind # User

# kind_of_user.===
# Can check if a given value is an instance of its kind.
kind_of_user === 0        # false
kind_of_user === User.new # true

# kind_of_user.value?(value)
# Can check if a given value is an instance of its kind.
kind_of_user.value?('')       # false
kind_of_user.value?(User.new) # true

# If it doesn't receive an argument, a lambda will be returned and it will know how to do the type verification.
[0, User.new].select(&kind_of_user.value?) # [#<User:0x0000.... >]

# kind_of_user.or_nil(value)
# Can return nil if the given value isn't an instance of its kind
kind_of_user.or_nil({})       # nil
kind_of_user.or_nil(User.new) # #<User:0x0000.... >

# kind_of_user.or_undefined(value)
# Can return Kind::Undefined if the given value isn't an instance of its kind
kind_of_user.or_undefined([])       # Kind::Undefined
kind_of_user.or_undefined(User.new) # #<User:0x0000.... >

# kind_of_user.or(fallback, value)
# Can return a fallback if the given value isn't an instance of its kind
kind_of_user.or(nil, 0)        # nil
kind_of_user.or(nil, User.new) # #<User:0x0000.... >

# If it doesn't receive a second argument (the value), it will return a callable that knows how to expose an instance of the expected type or a fallback if the given value was wrong.
[1, User.new].map(&kind_of_user.or(nil)) # [nil, #<User:0x0000.... >]

# An error will be raised if the fallback didn't have the expected kind or if not nil / Kind::Undefined.
[0, User.new].map(&kind_of_user.or(:foo)) # Kind::Error (:foo expected to be a kind of User)

# kind_of_user[value]
# Will raise Kind::Error if the given value isn't an instance of the expected kind
kind_of_user[:foo]     # Kind::Error (:foo expected to be a kind of User)
kind_of_user[User.new] # #<User:0x0000.... >

# kind_of_user.value(arg, default:)
# This method ensures that you will have a value of the expected kind. But, in the case of the given value be invalid, this method will require a default value (with the expected kind) to be returned.
kind_of_user.value(User.new, default: User.new) # #<User:0x0000...>

kind_of_user.value('1', default: User.new)      # #<User:0x0000...>

kind_of_user.value('1', default: 1)  # Kind::Error (1 expected to be a kind of User)

# kind_of_user.maybe
# This method returns a typed Kind::Maybe.
kind_of_user.maybe('1').value_or(User.new) # #<User:0x0000...>
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

##### Using Kind.object(name:, &block)

```ruby
PositiveInteger = Kind.object(name: 'PositiveInteger') do |value|
  value.kind_of?(Integer) && value > 0
end

# PositiveInteger.name
# PositiveInteger.kind
# The type handler can return its kind and its name
PositiveInteger.name # "PositiveInteger"
PositiveInteger.kind # #<Proc:0x0000.... >

# PositiveInteger.===
# Can check if a given value is an instance of its kind.
PositiveInteger === 1 # true
PositiveInteger === 0 # false

# PositiveInteger.value?(value)
# Can check if a given value is an instance of its kind.
PositiveInteger.value?(1)  # true
PositiveInteger.value?(-1) # false

# If it doesn't receive an argument, a lambda will be returned and it will know how to do the type verification.
[1, 2, 0, 3, -1].select(&PositiveInteger.value?) # [1, 2, 3]

# PositiveInteger.or_nil(value)
# Can return nil if the given value isn't an instance of its kind
PositiveInteger.or_nil(1) # 1
PositiveInteger.or_nil(0) # nil

# PositiveInteger.or_undefined(value)
# Can return Kind::Undefined if the given value isn't an instance of its kind
PositiveInteger.or_undefined(2)  # 2
PositiveInteger.or_undefined(-1) # Kind::Undefined

# PositiveInteger.or(fallback, value)
# Can return a fallback if the given value isn't an instance of its kind
PositiveInteger.or(nil, 1) # 1
PositiveInteger.or(nil, 0) # nil

# If it doesn't receive a second argument (the value), it will return a callable that knows how to expose an instance of the expected type or a fallback if the given value was wrong.
[1, 2, 0, 3, -1].map(&PositiveInteger.or(1))   # [1, 2, 1, 3, 1]
[1, 2, 0, 3, -1].map(&PositiveInteger.or(nil)) # [1, 2, nil, 3, nil]

# An error will be raised if the fallback didn't have the expected kind or if not nil / Kind::Undefined.
[1, 2, 0, 3, -1].map(&PositiveInteger.or(:foo)) # Kind::Error (:foo expected to be a kind of PositiveInteger)

# PositiveInteger[value]
# Will raise Kind::Error if the given value isn't an instance of the expected kind
PositiveInteger[1]    # 1
PositiveInteger[:foo] # Kind::Error (:foo expected to be a kind of PositiveInteger)

# PositiveInteger.value(arg, default:)
# This method ensures that you will have a value of the expected kind. But, in the case of the given value be invalid, this method will require a default value (with the expected kind) to be returned.
PositiveInteger.value(2, default: 1)   # 2

PositiveInteger.value('1', default: 1) # 1

PositiveInteger.value('1', default: 0) # Kind::Error (0 expected to be a kind of PositiveInteger)

# PositiveInteger.maybe
# This method returns a typed Kind::Maybe.
PositiveInteger.maybe(0).value_or(1) # 1

PositiveInteger.maybe(2).value_or(1) # 2
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind::<Type> object

The idea here is to create a type handler inside of the `Kind` namespace and to do this you will only need to use pure Ruby. e.g:

```ruby
class User
end

module Kind
  module User
    extend self, ::Kind::Object

    # Define the expected kind of this type handler.
    def kind; ::User; end
  end

  # This how the Kind::<Type>? methods are defined.
  def self.User?(*values)
    KIND.of?(::User, values)
  end
end

# Doing this you will have the same methods of a standard type handler (like: `Kind::Symbol`).

user = User.new

Kind::User[user] # #<User:0x0000...>
Kind::User[{}]   # Kind::Error ({} expected to be a kind of User)

Kind::User?(user) # true
Kind::User?({})   # false
```

The advantages of this approach are:

1. You will have a singleton (a unique instance) to be used, so the garbage collector will work less.
2. You can define additional methods to be used with this kind.

The disadvantage is:

1. You could overwrite some standard type handler or constant. I believe that this will be hard to happen, but must be your concern if you decide to use this kind of approach.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Utility methods

#### Kind.of_class?()

This method verify if a given value is a `Class`.

```ruby
Kind.of_class?(Hash)       # true
Kind.of_class?(Enumerable) # false
Kind.of_class?(1)          # false
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.of_module?()

This method verify if a given value is a `Module`.

```ruby
Kind.of_module?(Hash)       # false
Kind.of_module?(Enumerable) # true
Kind.of_module?(1)          # false
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.of_module_or_class()

This method return the given value if it is a module or a class. If not, a `Kind::Error` will be raised.

```ruby
Kind.of_module_or_class(String) # String
Kind.of_module_or_class(1)      # Kind::Error (1 expected to be a kind of Module/Class)
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.respond_to()

this method returns the given object if it responds to all of the method names. But if the object does not respond to some of the expected methods, an error will be raised.
  ```ruby
  Kind.respond_to('', :upcase)         # ""
  Kind.respond_to('', :upcase, :strip) # ""

  Kind.respond_to(1, :upcase)        # expected 1 to respond to :upcase
  Kind.respond_to(2, :to_s, :upcase) # expected 2 to respond to :upcase
  ```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.of()

There is a second way to do a strict type verification, you can use the `Kind.of()` method to do this. It receives the kind as the first argument and the value to be checked as the second one.
```ruby
Kind.of(Hash, {}) # {}
Kind.of(Hash, []) # Kind::Error ([] expected to be a kind of Hash)
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.of?()

This method can be used to check if one or multiple values have the expected kind.

```ruby
# Checking one value
Kind.of?(Array, []) # true
Kind.of?(Array, {}) # false

# Checking multiple values
Kind.of?(Enumerable, [], {}) # true
Kind.of?(Hash, {}, {})       # true
Kind.of?(Array, [], {})      # false
```

If the method receives only the first argument (the kind) a lambda will be returned and it will know how to do the type verification.

```ruby
[1, '2', 3].select(&Kind.of?(Numeric)) # [1, 3]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.value()

This method ensures that you will have a value of the expected kind. But, in the case of the given value be invalid, this method will require a default value (with the expected kind) to be returned.
```ruby
Kind.value(String, '1', default: '') # "1"

Kind.value(String, 1, default: '')   # ""

Kind.value(String, 1, default: 2)    # Kind::Error (2 expected to be a kind of String)
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind.is()

You can use `Kind.is` to verify if some class has the expected type as its ancestor.

```ruby
Kind.is(Hash, String) # false

Kind.is(Hash, Hash)   # true

Kind.is(Enumerable, Hash) # true
```

The `Kind.is` also could check the inheritance of Classes/Modules.

```ruby
#
# Verifying if a class is or inherits from the expected class.
#
class Human; end
class Person < Human; end
class User < Human; end

Kind.is(Human, User)   # true
Kind.is(Human, Human)  # true
Kind.is(Human, Person) # true

Kind.is(Human, Struct) # false

#
# Verifying if the classes included a module.
#
module Human; end
class Person; include Human; end
class User; include Human; end

Kind.is(Human, User)   # true
Kind.is(Human, Human)  # true
Kind.is(Human, Person) # true

Kind.is(Human, Struct) # false

#
# Verifying if a class is or inherits from the expected module.
#
module Human; end
module Person; extend Human; end
module User; extend Human; end

Kind.is(Human, User)   # true
Kind.is(Human, Human)  # true
Kind.is(Human, Person) # true

Kind.is(Human, Struct) # false
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Utility modules

#### Kind::Try

The method `.call` of this module invokes a public method with or without arguments like `public_send` does, except that if the receiver does not respond to it the call returns `nil` rather than raising an exception.

```ruby
Kind::Try.(' foo ', :strip)        # "foo"
Kind::Try.({a: 1}, :[], :a)        # 1
Kind::Try.({a: 1}, :[], :b)        # nil
Kind::Try.({a: 1}, :fetch, :b, 2)  # 2

Kind::Try.(:symbol, :strip)        # nil
Kind::Try.(:symbol, :fetch, :b, 2) # nil

# It raises an exception if the method name isn't a string or a symbol
Kind::Try.({a: 1}, 1, :a) # TypeError (1 is not a symbol nor a string)
```

This module has the method `[]` that knows how to create a lambda that will know how to perform the `try` strategy.

```ruby
results =
  [
    {},
    {name: 'Foo Bar'},
    {name: 'Rodrigo Serradura'},
  ].map(&Kind::Try[:fetch, :name, 'John Doe'])

p results # ["John Doe", "Foo Bar", "Rodrigo Serradura"]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind::Dig

The method `.call` of this module has the same behavior of Ruby dig methods ([Hash](https://ruby-doc.org/core-2.3.0/Hash.html#method-i-dig), [Array](https://ruby-doc.org/core-2.3.0/Array.html#method-i-dig), [Struct](https://ruby-doc.org/core-2.3.0/Struct.html#method-i-dig), [OpenStruct](https://ruby-doc.org/stdlib-2.3.0/libdoc/ostruct/rdoc/OpenStruct.html#method-i-dig)), but it will not raise an error if some step can't be digged.

```ruby
s = Struct.new(:a, :b).new(101, 102)
o = OpenStruct.new(c: 103, d: 104)
d = { struct: s, ostruct: o, data: [s, o]}

Kind::Dig.(s, [:a])            # 101
Kind::Dig.(o, [:c])            # 103

Kind::Dig.(d, [:struct, :b])   # 102
Kind::Dig.(d, [:data, 0, :b])  # 102
Kind::Dig.(d, [:data, 0, 'b']) # 102

Kind::Dig.(d, [:ostruct, :d])  # 104
Kind::Dig.(d, [:data, 1, :d])  # 104
Kind::Dig.(d, [:data, 1, 'd']) # 104

Kind::Dig.(d, [:struct, :f])   # nil
Kind::Dig.(d, [:ostruct, :f])  # nil
Kind::Dig.(d, [:data, 0, :f])  # nil
Kind::Dig.(d, [:data, 1, :f])  # nil
```

Another difference between the `Kind::Dig` and the native Ruby dig, is that it knows how to extract values from regular objects.

```ruby
class Person
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

person = Person.new('Rodrigo')

Kind::Dig.(person, [:name])                         # "Rodrigo"

Kind::Dig.({people: [person]}, [:people, 0, :name]) # "Rodrigo"
```

This module has the method `[]` that knows how to create a lambda that will know how to perform the `dig` strategy.

```ruby
results = [
  { person: {} },
  { person: { name: 'Foo Bar'} },
  { person: { name: 'Rodrigo Serradura'} },
].map(&Kind::Dig[:person, :name])

p results # [nil, "Foo Bar", "Rodrigo Serradura"],
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Kind::Presence

The method `.call` of this module returns the given value if it's present otherwise it will return `nil`.

```ruby
Kind::Presence.(true)         # true
Kind::Presence.('foo')        # "foo"
Kind::Presence.([1, 2])       # [1, 2]
Kind::Presence.({a: 3})       # {a: 3}
Kind::Presence.(Set.new([4])) # #<Set: {4}>

Kind::Presence.('')       # nil
Kind::Presence.('   ')    # nil
Kind::Presence.("\t\n\r") # nil
Kind::Presence.("\u00a0") # nil

Kind::Presence.([])       # nil
Kind::Presence.({})       # nil
Kind::Presence.(Set.new)  # nil

Kind::Presence.(nil)      # nil
Kind::Presence.(false)    # nil

# nil will be returned if the given object responds to the method blank? and this method result is true.
MyObject = Struct.new(:is_blank) do
  def blank?
    is_blank
  end
end

my_object = MyObject.new

my_object.is_blank = true

Kind::Presence.(my_object) # nil

my_object.is_blank = false

Kind::Presence.(my_object) # #<struct MyObject is_blank=false>
```

This module also has the method `to_proc`, because of this you can make use of the `Kind::Presence` in methods that receive a block as an argument. e.g:

```ruby
  ['', [], {}, '1', [2]].map(&Kind::Presence) # [nil, nil, nil, "1", [2]]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Kind::Undefined

The [`Kind::Undefined`](https://github.com/serradura/kind/blob/main/lib/kind/basic/undefined.rb) constant can be used to distinguish the usage of `nil`.

If you are interested, check out [the tests](https://github.com/serradura/kind/blob/main/test/kind/basic/undefined_test.rb) to understand its methods.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Kind::Maybe

The `Kind::Maybe` is used when a series of computations (in a chain of map callings) could return `nil` or `Kind::Undefined` at any point.

```ruby
optional =
  Kind::Maybe.new(2)
             .map { |value| value * 2 }
             .map { |value| value * 2 }

puts optional.value # 8
puts optional.some? # true
puts optional.none? # false
puts optional.value_or(0) # 8
puts optional.value_or { 0 } # 8

#################
# Returning nil #
#################

optional =
  Kind::Maybe.new(3)
             .map { nil }
             .map { |value| value * 3 }

puts optional.value # nil
puts optional.some? # false
puts optional.none? # true
puts optional.value_or(0) # 0
puts optional.value_or { 0 } # 0

#############################
# Returning Kind::Undefined #
#############################

optional =
  Kind::Maybe.new(4)
             .map { Kind::Undefined }
             .map { |value| value * 4 }

puts optional.value # Kind::Undefined
puts optional.some? # false
puts optional.none? # true
puts optional.value_or(1) # 1
puts optional.value_or { 1 } # 1
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Replacing blocks by lambdas

```ruby
Add = -> params do
  a, b = Kind::Hash.value_or_empty(params).values_at(:a, :b)

  a + b if Kind::Numeric?(a, b)
end

# --

  Kind::Maybe.new(a: 1, b: 2).map(&Add).value_or(0) # 3

  # --

  Kind::Maybe.new([]).map(&Add).value_or(0) # 0
  Kind::Maybe.new({}).map(&Add).value_or(0) # 0
  Kind::Maybe.new(nil).map(&Add).value_or(0) # 0
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe[], Kind::Maybe.wrap() and Kind::Maybe#then method aliases

You can use `Kind::Maybe[]` (brackets) instead of the `.new` to transform values in a `Kind::Maybe`. Another alias is `.then` to the `.map` method.

```ruby
result =
  Kind::Maybe[5]
    .then { |value| value * 5 }
    .then { |value| value + 17 }
    .value_or(0)

puts result # 42
```

You can also use `Kind::Maybe.wrap()` instead of the `.new` method.

```ruby
result =
  Kind::Maybe
    .wrap(5)
    .then { |value| value * 5 }
    .then { |value| value + 17 }
    .value_or(0)

puts result # 42
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Replacing blocks by lambdas

```ruby
Add = -> params do
  a, b = Kind::Hash.value_or_empty(params).values_at(:a, :b)

  a + b if Kind::Numeric?(a, b)
end

# --

Kind::Maybe[a: 1, b: 2].then(&Add).value_or(0) # 3

# --

Kind::Maybe[1].then(&Add).value_or(0) # 0
Kind::Maybe['2'].then(&Add).value_or(0) # 0
Kind::Maybe[nil].then(&Add).value_or(0) # 0
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::None() and Kind::Some()

If you need to ensure the return of  `Kind::Maybe` results from your methods/lambdas,
you could use the methods `Kind::None` and `Kind::Some` to do this. e.g:

```ruby
Double = ->(arg) do
  number = Kind::Numeric.or_nil(arg)

  Kind::Maybe[number].then { |number| number * 2 }
end

Add = -> params do
  a, b = Kind::Hash.value_or_empty(params).values_at(:a, :b)

  return Kind::None unless Kind::Numeric?(a, b)

  Kind::Some(a + b)
end

# --

Add.call(1)    # #<Kind::Maybe::None:0x0000... @value=nil>
Add.call({})   # #<Kind::Maybe::None:0x0000... @value=nil>
Add.call(a: 1) # #<Kind::Maybe::None:0x0000... @value=nil>
Add.call(b: 2) # #<Kind::Maybe::None:0x0000... @value=nil>

Add.call(a:1, b: 2) # #<Kind::Maybe::Some:0x0000... @value=3>

# --

Kind::Maybe[a: 1, b: 2].then(&Add).value_or(0) # 3

Kind::Maybe[1].then(&Add).value_or(0) # 0

# --

Add.(a: 2, b: 2).then(&Double).value # 8
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Optional

The `Kind::Optional` constant is an alias for `Kind::Maybe`. e.g:

```ruby
result1 =
  Kind::Optional
    .new(5)
    .map { |value| value * 5 }
    .map { |value| value - 10 }
    .value_or(0)

puts result1 # 15

# ---

result2 =
  Kind::Optional[5]
    .then { |value| value * 5 }
    .then { |value| value + 10 }
    .value_or { 0 }

puts result2 # 35
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Replacing blocks by lambdas

```ruby
Double = ->(arg) do
  number = Kind::Numeric.or_nil(arg)

  Kind::Maybe[number].then { |number| number * 2 }
end

# --

Kind::Optional[2].then(&Double).value_or(0) # 4

# --

Kind::Optional['2'].then(&Double).value_or(0) # 0
Kind::Optional[nil].then(&Double).value_or(0) # 0
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe(<Type>)

You can use `Kind::Maybe(<Type>)` or `Kind::Optional(<Type>)` to create a maybe monad which will return None if the given input hasn't the expected type. e.g:

```ruby
result1 =
  Kind::Maybe(Numeric)
    .wrap(5)
    .then { |value| value * 5 }
    .value_or { 0 }

puts result1 # 25

# ---

result2 =
  Kind::Optional(Numeric)
    .wrap('5')
    .then { |value| value * 5 }
    .value_or { 0 }

puts result2 # 0
```

This typed maybe has the same methods of `Kind::Maybe` class. e.g:

```ruby
Kind::Maybe(Numeric)[5]
Kind::Maybe(Numeric).new(5)
Kind::Maybe(Numeric).wrap(5)

# ---

Kind::Optional(Numeric)[5]
Kind::Optional(Numeric).new(5)
Kind::Optional(Numeric).wrap(5)
```

#### Real world examples

It is very common the need to avoid some operation when a method receives the wrong input.
In these scenarios, you could create a maybe monad that will return None if the given input hasn't the expected type. e.g:

```ruby
def person_name(params)
  Kind::Maybe(Hash)
    .wrap(params)
    .then  { |hash| hash.values_at(:first_name, :last_name) }
    .then  { |names| names.map(&Kind::Presence).tap(&:compact!) }
    .check { |names| names.size == 2 }
    .then  { |(first_name, last_name)| "#{first_name} #{last_name}" }
    .value_or { 'John Doe' }
end

person_name('')   # "John Doe"
person_name(nil)  # "John Doe"

person_name(first_name: 'Rodrigo')   # "John Doe"
person_name(last_name: 'Serradura')  # "John Doe"

person_name(first_name: 'Rodrigo', last_name: 'Serradura') # "Rodrigo Serradura"

#
# See below the previous implementation without using the maybe monad.
#
def person_name(params)
  default = 'John Doe'

  return default unless params.kind_of?(Hash)

  names = params.values_at(:first_name, :last_name).map(&Kind::Presence).tap(&:compact!)

  return default if names.size != 2

  first_name, last_name = names

  "#{first_name} #{last_name}"
end
```

To finish follows an example of how to use the Maybe monad to handle arguments in coupled methods.

```ruby
module PersonIntroduction1
  extend self

  def call(params)
    optional = Kind::Maybe(Hash).wrap(params)

    "Hi my name is #{full_name(optional)}, I'm #{age(optional)} years old."
  end

  private

    def full_name(optional)
      optional.map { |hash| "#{hash[:first_name]} #{hash[:last_name]}".strip }
              .presence
              .value_or { 'John Doe' }
    end

    def age(optional)
      optional.dig(:age).value_or(0)
    end
end

#
# See below the previous implementation without using an optional.
#
module PersonIntroduction2
  extend self

  def call(params)
    "Hi my name is #{full_name(params)}, I'm #{age(params)} years old."
  end

  private

    def full_name(params)
      default = 'John Doe'

      case params
      when Hash then
        Kind::Presence.("#{params[:first_name]} #{params[:last_name]}".strip) || default
      else default
      end
    end

    def age(params)
      case params
      when Hash then params.fetch(:age, 0)
      else 0
      end
    end
end
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Error handling

#### Kind::Maybe.wrap {}

The `Kind::Maybe#wrap` can receive a block, and if an exception (at `StandardError level`) happening, this will generate a None result.

```ruby
Kind::Maybe(Numeric)
  .wrap { 2 / 0 } # #<Kind::Maybe::None:0x0000... @value=#<ZeroDivisionError: divided by 0>>

Kind::Maybe(Numeric)
  .wrap(2) { |number| number / 0 } # #<Kind::Maybe::None:0x0000... @value=#<ZeroDivisionError: divided by 0>>
```

#### Kind::Maybe.map! or Kind::Maybe.then!

By default the `Kind::Maybe#map` and `Kind::Maybe#then` intercept exceptions at the `StandardError` level. So if an exception was intercepted a None will be returned.

```ruby
# Handling StandardError exceptions
result1 = Kind::Maybe[2].map { |number| number / 0 }
result1.none? # true
result1.value # #<ZeroDivisionError: divided by 0>

result2 = Kind::Maybe[3].then { |number| number / 0 }
result2.none? # true
result2.value # #<ZeroDivisionError: divided by 0>
```

But there are versions of these methods (`Kind::Maybe#map!` and `Kind::Maybe#then!`) that allow the exception leak, so, the user must handle the exception by himself or use this method when he wants to see the error be raised.

```ruby
# Leaking StandardError exceptions
Kind::Maybe[2].map! { |number| number / 0 } # ZeroDivisionError (divided by 0)

Kind::Maybe[2].then! { |number| number / 0 } # ZeroDivisionError (divided by 0)
```

> **Note:** If an exception (at StandardError level) is returned by the methods `#then`, `#map` it will be resolved as None.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe#try

If you don't want to use `#map/#then` to access the value, you could use the `#try` method to access it. So, if the value wasn't `nil` or `Kind::Undefined`, the some monad will be returned.

```ruby
object = 'foo'

Kind::Maybe[object].try(:upcase).value # "FOO"

Kind::Maybe[{}].try(:fetch, :number, 0).value # 0

Kind::Maybe[{number: 1}].try(:fetch, :number).value # 1

Kind::Maybe[object].try { |value| value.upcase }.value # "FOO"

#############
# Nil value #
#############

object = nil

Kind::Maybe[object].try(:upcase).value # nil

Kind::Maybe[object].try { |value| value.upcase }.value # nil

#########################
# Kind::Undefined value #
#########################

object = Kind::Undefined

Kind::Maybe[object].try(:upcase).value # nil

Kind::Maybe[object].try { |value| value.upcase }.value # nil
```

> **Note:** You can use the `#try` method with `Kind::Optional` objects.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe#try!

Has the same behavior of its `#try`, but it will raise an error if the value doesn't respond to the expected method.

```ruby
Kind::Maybe[{}].try(:upcase)  # => #<Kind::Maybe::None:0x0000... @value=nil>

Kind::Maybe[{}].try!(:upcase) # => NoMethodError (undefined method `upcase' for {}:Hash)
```

> **Note:** You can also use the `#try!` method with `Kind::Optional` objects.

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe#dig

Has the same behavior of Ruby dig methods ([Hash](https://ruby-doc.org/core-2.3.0/Hash.html#method-i-dig), [Array](https://ruby-doc.org/core-2.3.0/Array.html#method-i-dig), [Struct](https://ruby-doc.org/core-2.3.0/Struct.html#method-i-dig), [OpenStruct](https://ruby-doc.org/stdlib-2.3.0/libdoc/ostruct/rdoc/OpenStruct.html#method-i-dig)), but it will not raise an error if some value can't be digged.

```ruby
[nil, 1, '', /x/].each do |value|
  p Kind::Maybe[value].dig(:foo).value # nil
end

# --

a = [1, 2, 3]

Kind::Maybe[a].dig(0).value # 1

Kind::Maybe[a].dig(3).value # nil

# --

h = { foo: {bar: {baz: 1}}}

Kind::Maybe[h].dig(:foo).value             # {bar: {baz: 1}}
Kind::Maybe[h].dig(:foo, :bar).value       # {baz: 1}
Kind::Maybe[h].dig(:foo, :bar, :baz).value # 1

Kind::Maybe[h].dig(:foo, :bar, 'baz').value # nil

# --

i = { foo: [{'bar' => [1, 2]}, {baz: [3, 4]}] }

Kind::Maybe[i].dig(:foo, 0, 'bar', 0).value # 1
Kind::Maybe[i].dig(:foo, 0, 'bar', 1).value # 2
Kind::Maybe[i].dig(:foo, 0, 'bar', -1).value # 2

Kind::Maybe[i].dig(:foo, 0, 'bar', 2).value # nil

# --

s = Struct.new(:a, :b).new(101, 102)
o = OpenStruct.new(c: 103, d: 104)
b = { struct: s, ostruct: o, data: [s, o]}

Kind::Maybe[s].dig(:a).value            # 101
Kind::Maybe[b].dig(:struct, :b).value   # 102
Kind::Maybe[b].dig(:data, 0, :b).value  # 102
Kind::Maybe[b].dig(:data, 0, 'b').value # 102

Kind::Maybe[o].dig(:c).value            # 103
Kind::Maybe[b].dig(:ostruct, :d).value  # 104
Kind::Maybe[b].dig(:data, 1, :d).value  # 104
Kind::Maybe[b].dig(:data, 1, 'd').value # 104

Kind::Maybe[s].dig(:f).value           # nil
Kind::Maybe[o].dig(:f).value           # nil
Kind::Maybe[b].dig(:struct, :f).value  # nil
Kind::Maybe[b].dig(:ostruct, :f).value # nil
Kind::Maybe[b].dig(:data, 0, :f).value # nil
Kind::Maybe[b].dig(:data, 1, :f).value # nil
```

> **Note:** You can also use the `#dig` method with `Kind::Optional` objects.

### Kind::Maybe#check

This method will return the current Some after verify if the block output is truthy. e.g:

```ruby
Kind::Maybe(Array)
  .wrap(['Rodrigo', 'Serradura'])
  .then  { |names| names.map(&Kind::Presence).tap(&:compact!) }
  .check { |names| names.size == 2 }
  .value # ["Rodrigo", "Serradura"]
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Kind::Maybe#presence

This method will return None if the wrapped value wasn't present.

```ruby
result = Kind::Maybe(Hash).wrap(foo: '').dig(:foo).presence
result.none? # true
result.value # nil
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Kind::Empty

When you define a method that has default arguments, for certain data types, you will always create a new object in memory. e.g:

```ruby
def something(params = {})
  params.object_id
end

puts something # 70312470300460
puts something # 70312470295800
puts something # 70312470278400
puts something # 70312470273800
```

So, to avoid an unnecessary allocation in memory, the `kind` gem exposes some frozen objects to be used as default values.

- `Kind::Empty::SET`
- `Kind::Empty::HASH`
- `Kind::Empty::ARRAY`
- `Kind::Empty::STRING`

Usage example:

```ruby
def do_something(value, with_options: Kind::Empty::HASH)
  # ...
end
```

### Defining Empty as Kind::Empty an alias

You can require `kind/empty/constant` to define `Empty` as a `Kind::Empty` alias. But, a `LoadError` will be raised if there is an already defined constant `Empty`.

So if you required this file, the previous example could be written like this:

```ruby
def do_something(value, with_options: Empty::HASH)
  # ...
end
```

Follows the list of constants if the alias was defined:

- `Empty::SET`
- `Empty::HASH`
- `Empty::ARRAY`
- `Empty::STRING`

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Kind::Validator (ActiveModel::Validations)

This module enables the capability to validate types via [`ActiveModel::Validations >= 3.2, < 7.0`](https://api.rubyonrails.org/classes/ActiveModel/Validations.html). e.g

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :first_name, :last_name

  validates :first_name, :last_name, kind: String
end
```

And to make use of it, you will need to do an explicitly require. e.g:

```ruby
# In some Gemfile
gem 'kind', require: 'kind/validator'

# In some .rb file
require 'kind/validator'
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Usage

#### [Object#===](https://ruby-doc.org/core-3.0.0/Object.html#method-i-3D-3D-3D)

```ruby
validates :name, kind: { of: String }
```

Use an array to verify if the attribute is an instance of one of the classes/modules.

```ruby
validates :status, kind: { of: [String, Symbol]}
```

Because of kind verification be made via `===` you can use type handlers as the expected kinds.

```ruby
validates :alive, kind: Kind::Boolean
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### [Kind.is](#verifying-the-kind-of-some-classmodule)

```ruby
#
# Verifying if the attribute value is the class or a subclass.
#
class Human; end
class Person < Human; end
class User < Human; end

validates :human_kind, kind: { is: Human }

#
# Verifying if the attribute value is the module or if it is a class that includes the module
#
module Human; end
class Person; include Human; end
class User; include Human; end

validates :human_kind, kind: { is: Human }

#
# Verifying if the attribute value is the module or if it is a module that extends the module
#
module Human; end
module Person; extend Human; end
module User; extend Human; end

validates :human_kind, kind: { is: Human }

# or use an array to verify if the attribute
# is a kind of one those classes/modules.

validates :human_kind, kind: { is: [Person, User] }
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### [Object#instance_of?](https://ruby-doc.org/core-3.0.0/Object.html#method-i-instance_of-3F)

```ruby
validates :name, kind: { instance_of: String }

# or use an array to verify if the attribute
# is an instance of one of the classes/modules.

validates :name, kind: { instance_of: [String, Symbol] }
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### [Object#respond_to?](https://ruby-doc.org/core-3.0.0/Object.html#method-i-respond_to-3F)

```ruby
validates :handler, kind: { respond_to: :call }
```

This validation can verify one or multiple methods.

```ruby
validates :params, kind: { respond_to: [:[], :values_at] }
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Array.new.all? { |item| item.kind_of?(Class) }

```ruby
validates :account_types, kind: { array_of: String }

# or use an array to verify if the attribute
# is an instance of one of the classes

validates :account_types, kind: { array_of: [String, Symbol] }
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

#### Array.new.all? { |item| expected_values.include?(item) }

```ruby
# Verifies if the attribute value
# is an array with some or all the expected values.

validates :account_types, kind: { array_with: ['foo', 'bar'] }
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Defining the default validation strategy

By default, you can define the attribute type directly (without a hash). e.g.

```ruby
validates :name, kind: String
# or
validates :name, kind: [String, Symbol]
```

To changes this behavior you can set another strategy to validates the attributes types:

```ruby
Kind::Validator.default_strategy = :instance_of

# Tip: Create an initializer if you are in a Rails application.
```

And these are the available options to define the default strategy:
-  `kind_of` *(default)*
-  `instance_of`

[⬆️ &nbsp;Back to Top](#table-of-contents-)

### Using the `allow_nil` and `strict` options

You can use the `allow_nil` option with any of the kind validations. e.g.

```ruby
validates :name, kind: String, allow_nil: true
```

And as any active model validation, kind validations works with the `strict: true`
option and with the `validates!` method. e.g.

```ruby
validates :first_name, kind: String, strict: true
# or
validates! :last_name, kind: String
```

[⬆️ &nbsp;Back to Top](#table-of-contents-)

## Similar Projects

- [dry-types](https://dry-rb.org/gems/dry-types)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/serradura/kind. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/serradura/kind/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kind project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/serradura/kind/blob/master/CODE_OF_CONDUCT.md).
