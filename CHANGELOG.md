# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.1] - 2026-05-24

### Added

- This `CHANGELOG.md`, rewritten to follow the [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) spec and backfilled to cover every tagged release from `0.1.0` through `6.0.1` (including the previously undocumented `3.0.1` patch and the `6.0.0` major).
- `bug_tracker_uri` entry in `spec.metadata` so RubyGems.org surfaces a direct link to the issue tracker from the gem page.

## [6.0.0] - 2026-05-23

### Changed

- **BREAKING:** Bumped minimum Ruby to **2.7.0** (Ruby 2.1 – 2.6 are EOL and no longer supported).
- Modernized the CI/test runner via Appraisal (mirroring the `u-case` 5.0 layout): the per-Ruby `ENV`-switched `Gemfile` and `bin/test` / `bin/prepare_coverage` scripts were replaced with an `Appraisals` file gated on `RUBY_VERSION`, the GitHub Actions matrix now covers Ruby 2.7 – 4.0+head with conditional ActiveModel steps, and per-module (`KIND_BASIC`) and `KIND_STRICT` runs are preserved as matrix axes.
- Switched code coverage reporting from CodeClimate to **Qlty** (token-based upload, badges updated in README).
- README polish: new header/badge layout, refreshed Ruby × ActiveModel compatibility table, added Ruby × Rails CI support matrix, and installation example pinned to `~> 6.0`. Pre-5.x rows dropped from the Documentation and Compatibility tables (long EOL).
- Ruby 3.4+/4.0 compatibility: rebuild `Kind::Any`'s brace-list `inspect` from values directly so the name stays `Kind::Any{:low, :high}` across the Ruby 4.0 `Set#inspect` format change; tests updated for the 3.4 quote/hash-literal display changes.

### Added

- [#71](https://github.com/u-gems/kind/pull/71) - Add `Kind::Maybe#to_proc` (thanks @tomascco), so `Kind::Maybe` can be passed where a block-arg is expected.
  ```ruby
  result = operation_that_can_return_nil().then(&Kind::Maybe)
  # => #<Kind::Some value=:result>
  ```
- Appraisal-generated gemfiles for **Rails 8.1** and **Rails edge**.
- `bin/matrix` script and `rake matrix` task to run the full local test matrix.
- `bin/setup` script.

### Removed

- `bin/test` and `bin/prepare_coverage` (replaced by the Appraisal-driven setup).

### Security

- Hardened the GitHub Actions workflow: least-privilege `contents: read` permissions on the test job and `persist-credentials: false` on `actions/checkout`.

## [5.10.0] - 2021-09-23

### Added

- [#69](https://github.com/u-gems/kind/pull/69) - Make `Kind::Any` work with a `Set`.

  ```ruby
  require 'kind/any'

  Kind::Any.new(Set[:low, :high]).inspect       # Kind::Any{:low, :high}
  Kind::Any.new(Array['open', 'close']).inspect # Kind::Any["open", "close"]
  ```

## [5.9.0] - 2021-09-22

### Added

- [#68](https://github.com/u-gems/kind/pull/68) - Add `Kind.object(name:, &block)` to create `Kind::Objects` (custom type handlers) with the full handler API: `.name`, `.kind`, `.===`, `.value?`, `.or_nil`, `.or_undefined`, `.or(fallback)`, `.[]`, `.value(arg, default:)`, and `.maybe`.

  ```ruby
  PositiveInteger = Kind.object(name: 'PositiveInteger') do |value|
    value.kind_of?(Integer) && value > 0
  end

  PositiveInteger === 1                 # true
  PositiveInteger.or_nil(0)             # nil
  PositiveInteger[:foo]                 # Kind::Error (:foo expected to be a kind of PositiveInteger)
  PositiveInteger.value(2, default: 1)  # 2
  PositiveInteger.maybe(0).value_or(1)  # 1
  ```

## [5.8.1] - 2021-09-22

### Fixed

- [#67](https://github.com/u-gems/kind/pull/67) - Make `Kind.assert_hash!(some_hash, schema:)` work with a `Kind::Any` instance.

  ```ruby
  require 'kind/any'

  Level = Kind::Any[:low, :high]

  Kind.assert_hash!({level: :medium}, schema: {level: Level})
  # Kind::Error (The key :status has an invalid value. Expected: Kind::Any[:low, :high])
  ```

## [5.8.0] - 2021-09-22

### Added

- [#66](https://github.com/u-gems/kind/pull/66) - Add `Kind::Any` to verify a value belongs to a list of expected values.

  ```ruby
  require 'kind/any'

  Level = Kind::Any[:low, :high] # or Kind::Any.new([:low, :high])

  Level === :low   # true
  Level === :foo   # false
  Level[:low]      # :low
  Level[:foo]      # Kind::Error (:foo expected to be a kind of Kind::Any[:low, :high])
  Level.values     # [:low, :high]
  ```

- [#66](https://github.com/u-gems/kind/pull/66) - Add `Kind::Enum.from_array(arg, use_index_as_value:)` to allow the creation of enums where the values come from the array (either the values themselves or their indices).

  ```ruby
  module Level
    include Kind::Enum.from_array([:low, :medium, :high], use_index_as_value: false)
  end
  Level.values # [:low, :medium, :high]

  module Status
    include Kind::Enum.from_array([:open, :closed], use_index_as_value: true)
  end
  Status.values # [0, 1]
  ```

- [#66](https://github.com/u-gems/kind/pull/66) - Make `Kind.assert_hash!(hash, schema:)` work with `Kind::Object` instances.
- [#66](https://github.com/u-gems/kind/pull/66) - Improve the exception messages of `Kind.assert_hash!(hash, schema:)`.
- [#66](https://github.com/u-gems/kind/pull/66) - Make `Kind.assert_hash!(hash, **options)` raise `ArgumentError` if the given hash is empty.

## [5.7.0] - 2021-06-22

### Added

- [#58](https://github.com/u-gems/kind/pull/58) - Add `Kind.assert_hash!(hash, keys:)` with an optional `require_all:` to check the hash exposes exactly the expected keys.
  ```ruby
  Kind.assert_hash!({a: 1, b: 1}, keys: [:a, :b])
  Kind.assert_hash!({a: 1, b: 1}, keys: [:a]) # ArgumentError (Unknown key: :b. Valid keys are: :a)
  ```
- [#58](https://github.com/u-gems/kind/pull/58) - Add `Kind.assert_hash!(hash, schema:)` to validate hash shapes via literal values, classes, regexes or lambdas.
  ```ruby
  Kind.assert_hash!(hash, schema: {
    hash:   Enumerable,
    array:  Enumerable,
    email:  /\A.+@.+\..+\z/,
    string: String
  })
  ```

## [5.6.0] - 2021-05-14

### Added

- [#57](https://github.com/u-gems/kind/pull/57) - Allow `nil` in union-type definitions.
  ```ruby
  (Kind::String | nil) === ''  # true
  (Kind::String | nil) === nil # true
  (Kind::String | nil) === {}  # false
  ```

## [5.5.0] - 2021-04-05

### Added

- [#56](https://github.com/u-gems/kind/pull/56) - Add `Kind.or_nil()`.

  ```ruby
  Kind.or_nil(String, 1)  # nil
  Kind.or_nil(String, '') # ""

  filled_string = ->(value) { value.is_a?(String) && !value.empty? }
  Kind.or_nil(filled_string, '')  # nil
  Kind.or_nil(filled_string, '1') # "1"
  ```

## [5.4.1] - 2021-03-26

### Fixed

- [#55](https://github.com/u-gems/kind/pull/55) - Fix `Kind::Either::Left#value_or` and `Kind::Result::Failure#value_or` so a block call receives the underlying value of the monad.

## [5.4.0] - 2021-03-25

### Added

- [#54](https://github.com/u-gems/kind/pull/54) - Add `Kind::Functional::Steps`, allowing the use of `Step`, `Map`, `Try`, `Tee`, `Check`, `Success` and `Failure` in any object (classes and modules) to chain operations through `>>`.

  ```ruby
  class CreateUserJob < BaseJob
    include Kind::Functional::Steps

    def perform(input)
      validate(input) \
      >> Step(:create) \
      >> Step(:welcome_email)
    end

    private
      def validate(input);      end # Success() or Failure()
      def create(input);        end # Success() or Failure()
      def welcome_email(email); end # Success() or Failure()
  end
  ```

## [5.3.0] - 2021-03-23

### Added

- [#53](https://github.com/u-gems/kind/pull/53) - Allow `Kind::Result#map` and `Kind::Result#map!` to receive a callable.
- [#53](https://github.com/u-gems/kind/pull/53) - Add `|` and `>>` as aliases for `Kind::Result#map!`.
- [#53](https://github.com/u-gems/kind/pull/53) - Add step adapters (`Step`, `Map`, `Try`, `Tee`, `Check`) for `Kind::Action` and `Kind::Functional::Action`.

  ```ruby
  module CreateUser
    extend Kind::Functional::Action

    def call!(input)
      Step!(:validate, input) | Step(:create)
    end

    private
    def validate(input); end # returns Success(valid_data) or Failure(validation)
    def create(input);   end # returns Success(user)
  end
  ```

- [#53](https://github.com/u-gems/kind/pull/53) - Add `kind/strict/disabled` to turn off all strict validations (`Kind.of`, `Kind.of_class`, `Kind.of_module`, `Kind.of_module_or_class`, `Kind::<Type>[1]`, `Kind::NotNil[1]`) to optimize the runtime in production while keeping strict validation in development.

## [5.2.0] - 2021-03-17

### Added

- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind.respond_to?(method_name)` — behaves like the native `respond_to?` — and `Kind.respond_to?(object, *method_names)` to check an object implements a given set of methods.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::UnionType` for composing type checks via `|`, with `===`, `[]` and `#name`/`#inspect` returning e.g. `"(Array | Hash)"`.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Nil`, useful when composing union types: `Kind::UnionType[Hash] | Kind::Nil`.
- [#46](https://github.com/u-gems/kind/pull/46), [#47](https://github.com/u-gems/kind/pull/47) - Add `Kind::NotNil[value, label:]` for strict not-nil verification.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::RespondTo[*method_names]` for building duck-type checkers and composing them via `|`.
- [#46](https://github.com/u-gems/kind/pull/46) - Unfreeze the output of `Kind::Boolean.kind`.
- [#46](https://github.com/u-gems/kind/pull/46) - Freeze `Kind::UNDEFINED` and define its `inspect` method.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::TypeChecker#|` to compose union types (e.g. `Kind::String | Kind::Symbol`).
- [#46](https://github.com/u-gems/kind/pull/46) - Allow `Kind.of()` and `Kind::TypeChecker#[]` to receive a `label:` for clearer error messages.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `kind/basic`, a minimal entry point exposing just the type-handling essentials: `Kind.is?`, `Kind.of`, `Kind.of?`, `Kind.of_class?`, `Kind.of_module?`, `Kind.of_module_or_class`, `Kind.respond_to`, `Kind.respond_to?`, `Kind.value`, `Kind::Error`, `Kind::Undefined`.
- [#46](https://github.com/u-gems/kind/pull/46) - Improve `Kind::Maybe`: better `#inspect`; `Kind::Maybe.{new,[],wrap}` returns `None` when given an exception; add `#accept` (alias of `#check`) and `#reject` (its reverse); let `#map`, `#map!`, `#then`, `#then!`, `#check`, `#accept`, `#reject` accept a symbol (treated as a method to invoke on the wrapped value); add `Kind::Maybe#on` for block-based `some`/`none` handling.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Either` (either monad). Not loaded by default — `require 'kind/either'`. Provides `Kind::Left()`, `Kind::Right()`, `#right?`/`#left?`, `#map`/`#then` for chaining (auto-handle `StandardError` returning `Left`), and `#map!`/`#then!` variants that let exceptions leak.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Result` (an `Either` variation).
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Function`.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Functional`.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Try.presence` and improve the input/output handling of `Kind::Try.call`.
- [#46](https://github.com/u-gems/kind/pull/46) - Add `Kind::Dig.presence` and improve the input/output handling of `Kind::Dig.call`.
- [#47](https://github.com/u-gems/kind/pull/47) - Add `Kind.is!`.
- [#47](https://github.com/u-gems/kind/pull/47) - Add aliases `Kind.of!` (for `Kind.of`) and `Kind.respond_to!` (for `Kind.respond_to`).
- [#47](https://github.com/u-gems/kind/pull/47) - Add `Kind[]` as the replacement for `Kind::Of()`.
- [#49](https://github.com/u-gems/kind/pull/49) - Add `Kind::Either::Methods` and `Kind::Result::Methods`.
- [#49](https://github.com/u-gems/kind/pull/49) - Add `Kind::Undefined.empty?`.
- [#50](https://github.com/u-gems/kind/pull/50) - Add `Kind::<Type>.empty_or` as an alias of `Kind::<Type>.value_or_empty`.
- [#46](https://github.com/u-gems/kind/pull/46), [#51](https://github.com/u-gems/kind/pull/51) - Add `Kind::Functional::Action`.
- [#51](https://github.com/u-gems/kind/pull/51) - Add `Kind::Action`, `Kind::Maybe::ImmutableAttributes`, `Kind::Maybe::Methods`, and `Kind::Enum`.
- [#51](https://github.com/u-gems/kind/pull/51) - Modularize all the `kind` components: `kind/action`, `kind/dig`, `kind/either`, `kind/empty`, `kind/enum`, `kind/function`, `kind/functional`, `kind/functional/action`, `kind/immutable_attributes`, `kind/maybe`, `kind/objects`, `kind/presence`, `kind/result`, `kind/try`, `kind/validator`. `kind/action` is the minimal requirement for all of them.
- [#52](https://github.com/u-gems/kind/pull/52) - Improve `Kind::Validator` to accept lambdas or any object responding to `.===` and `.name` for kind validation.
- [#52](https://github.com/u-gems/kind/pull/52) - Add `Kind::Enum.===`.

### Changed

- [#48](https://github.com/u-gems/kind/pull/48) - Rename `Kind::TypeChecker` to `Kind::Object`, and `Kind::TypeChecker::Object` to `Kind::Object::Instance`.

### Deprecated

- [#47](https://github.com/u-gems/kind/pull/47) - Deprecate `Kind.is` and `Kind::Of()`.
- [#48](https://github.com/u-gems/kind/pull/48) - Deprecate `Kind::Maybe()` and `Kind::Optional()`.

## [5.1.0] - 2021-02-23

### Added

- [#45](https://github.com/u-gems/kind/pull/45) - Add support for Ruby `>= 2.1.0`.

### Deprecated

- [#45](https://github.com/u-gems/kind/pull/45) - `kind/active_model/validation` is deprecated; use `kind/validator` instead.

## [5.0.0] - 2021-02-22

### Changed

- [#44](https://github.com/u-gems/kind/pull/44) - **BREAKING:** The top-level `Empty` constant is no longer defined automatically. Require `kind/empty/constant` to opt in to defining `Empty` as a `Kind::Empty` alias.

### Removed

- [#44](https://github.com/u-gems/kind/pull/44) - Remove `Kind::Is.call`.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove `Kind::Of.call`.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove `Kind::Types.add`.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove `Kind::Of::<Type>` and `Kind::Is::<Type>` modules.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove `Kind::Checker`, `Kind::Checker::Protocol`, `Kind::Checker::Factory`.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove the invocation of `Kind.is` without arguments.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove the invocation of `Kind.of` without arguments.
- [#44](https://github.com/u-gems/kind/pull/44) - Remove the invocation of `Kind.of` with a single argument (the kind).

## [4.1.0] - 2021-02-22

### Added

- [#43](https://github.com/u-gems/kind/pull/43) - Make `Kind::Maybe::Typed` verify the kind of the value via `===`, enabling type checkers as the typed-`Maybe` kind.
  ```ruby
  Kind::Maybe(Kind::Boolean).wrap(nil).value_or(false)  # false
  Kind::Maybe(Kind::Boolean).wrap(true).value_or(false) # true
  ```
- [#43](https://github.com/u-gems/kind/pull/43) - Add `Kind::<Type>.maybe` and `Kind::<Type>.optional`. Without arguments, returns a typed `Maybe` with the expected kind; with arguments, behaves like `Kind::Maybe.wrap`.
- [#43](https://github.com/u-gems/kind/pull/43) - Make the `:respond_to` kind validation accept one or many method names: `validates :params, kind: { respond_to: [:[], :values_at] }`.
- [#43](https://github.com/u-gems/kind/pull/43) - Make the `:of` kind validation verify the expected value kind via `===`, allowing type checkers to be used as expected kinds: `validates :alive, kind: Kind::Boolean`.

## [4.0.0] - 2021-02-22

### Added

- [#40](https://github.com/u-gems/kind/pull/40) - Add `Kind.of_class?`, `Kind.of_module?`, and `Kind.of_module_or_class(value)` (returns the given value if it is a module/class, otherwise raises `Kind::Error`).
- [#40](https://github.com/u-gems/kind/pull/40) - Add `Kind.respond_to(object, *method_names)`: returns the object if it responds to all of the given methods, raises otherwise.
- [#40](https://github.com/u-gems/kind/pull/40) - Add `Kind::Try.call(receiver, method_name, *args)`: like `public_send`, but returns `nil` instead of raising when the receiver doesn't respond to the method.
- [#40](https://github.com/u-gems/kind/pull/40), [#41](https://github.com/u-gems/kind/pull/41) - Add `Kind::DEPRECATION` to warn about deprecations. Set `DISABLE_KIND_DEPRECATION` to silence the warnings.
- [#40](https://github.com/u-gems/kind/pull/40), [#41](https://github.com/u-gems/kind/pull/41) - Add **type checker modules** (`Kind::String`, `Kind::Integer`, etc.) exposing `.name`, `.kind`, `===`, `.value?`, `.or_nil`, `.or_undefined`, `.or(fallback)`, and `[value]`. The full list covers Core (`Array`, `Class`, `Comparable`, `Enumerable`, `Enumerator`, `File`, `Float`, `Hash`, `Integer`, `IO`, `Method`, `Module`, `Numeric`, `Proc`, `Queue`, `Range`, `Regexp`, `String`, `Struct`, `Symbol`, `Time`), Custom (`Boolean`, `Callable`, `Lambda`) and Stdlib (`OpenStruct`, `Set`).
- [#40](https://github.com/u-gems/kind/pull/40) - Add `Kind::Of(kind, name: ...)` to create type checkers in runtime from any object responding to `.===`.
  ```ruby
  PositiveInteger = Kind::Of(-> value { value.is_a?(Integer) && value > 0 }, name: 'PositiveInteger')
  PositiveInteger[1]    # 1
  PositiveInteger[:foo] # Kind::Error (:foo expected to be a kind of PositiveInteger)
  ```
- [#40](https://github.com/u-gems/kind/pull/40), [#41](https://github.com/u-gems/kind/pull/41) - Add **type checker methods** (`Kind::String?`, `Kind::Integer?`, etc.) that accept one or many values and return a lambda when called without arguments.
- [#41](https://github.com/u-gems/kind/pull/41) - Make `Kind::Dig.call` extract values from regular objects (not just `Hash`/`Array`/`Struct`/`OpenStruct`).
- [#41](https://github.com/u-gems/kind/pull/41) - Add `Kind::Presence.call`. Returns the given value if it is present, otherwise `nil`. Honors `#blank?` if defined on the object.
- [#41](https://github.com/u-gems/kind/pull/41) - Add `Kind::Maybe#presence` returning `None` if the wrapped value is not present.
- [#41](https://github.com/u-gems/kind/pull/41) - Make `Kind::Maybe#wrap` accept a block and intercept `StandardError` (returns `None` with the exception as its value).
- [#41](https://github.com/u-gems/kind/pull/41) - Make `Kind::Maybe#map`/`#then` intercept `StandardError` and return `None`. Add `#map!`/`#then!` for the leaking variants.
- [#41](https://github.com/u-gems/kind/pull/41) - Add `Kind::TypeCheckers#value(arg, default:)`, which ensures the returned value is of the expected kind (the default must also be of the kind).
- [#41](https://github.com/u-gems/kind/pull/41) - Add `value_or_empty` for `Kind::Array`, `Kind::Hash`, `Kind::String`, `Kind::Set` (returns an empty frozen value when the input has the wrong kind).
- [#42](https://github.com/u-gems/kind/pull/42) - Add `Kind.value(kind, arg, default:)`.
- [#42](https://github.com/u-gems/kind/pull/42) - Add `Kind::Presence.to_proc` (e.g. `[...].map(&Kind::Presence)`).
- [#42](https://github.com/u-gems/kind/pull/42) - Make `Kind::Maybe(<Type>).{new,[],wrap}` understand other `Maybe` monads as inputs (unwrapping their value).
- [#42](https://github.com/u-gems/kind/pull/42) - Make `Kind::Maybe(<Type>).wrap(arg) { |arg_value| }` verify the argument kind when the block declares it.
- [#42](https://github.com/u-gems/kind/pull/42) - Add `Kind::Maybe#check { ... }` returning the current `Some` if the block result is truthy, otherwise `None`.
- [#42](https://github.com/u-gems/kind/pull/42) - Add `Kind::Dig[]` and `Kind::Try[]` for building lambdas that perform the dig/try strategies.

### Deprecated

- [#40](https://github.com/u-gems/kind/pull/40) - Deprecate `Kind::Is.call`, `Kind::Of.call`, `Kind::Types.add`, the `Kind::Of::<Type>` / `Kind::Is::<Type>` modules, `Kind::Checker` (+ `Protocol` / `Factory`), and the bare-argument invocations of `Kind.is`/`Kind.of`.

### Fixed

- [#40](https://github.com/u-gems/kind/pull/40) - Make `Kind::Maybe.try!()` raise when called without a block or arguments.

## [3.1.0] - 2020-07-08

### Added

- [#33](https://github.com/u-gems/kind/pull/33) - Add `Kind::Of::OpenStruct` / `Kind::Is::OpenStruct`.
- [#33](https://github.com/u-gems/kind/pull/33) - Add `Kind::Maybe::Result#dig`. Extracts nested values; if any step returns `nil`, returns `None`, otherwise `Some(final_value)`.
- [#33](https://github.com/u-gems/kind/pull/33) - Add `Kind::Dig.call` utility. Same behavior as Ruby's `dig` (`Hash`, `Array`, `Struct`, `OpenStruct`) but returns `nil` instead of raising when a step cannot be digged.

## [3.0.1] - 2020-06-25

### Fixed

- [#32](https://github.com/u-gems/kind/pull/32) - Fix the `Kind::Maybe::None#try` methods.

## [3.0.0] - 2020-06-25

### Changed

- [#31](https://github.com/u-gems/kind/pull/31) - **BREAKING:** Change the behavior of `Kind::Maybe::Result#try()`. It now mirrors `public_send` semantics — returning `nil` when the receiver does not respond to the method — and wraps the result in `Some` when the value isn't `nil` / `Kind::Undefined`.
  ```ruby
  Kind::Maybe['foo'].try(:upcase).value             # "FOO"
  Kind::Maybe[{}].try(:fetch, :number, 0).value     # 0
  Kind::Optional[' Rodrigo '].try(:strip).value_or('') # "Rodrigo"
  ```

### Added

- [#31](https://github.com/u-gems/kind/pull/31) - Add `Kind::Maybe::Result#try!()` — like `#try`, but raises when the wrapped value does not respond to the method.

## [2.3.0] - 2020-06-24

### Added

- [#30](https://github.com/u-gems/kind/pull/30) - Add `Kind::Maybe.wrap()` as an alias for `Kind::Maybe.new()`.
- [#30](https://github.com/u-gems/kind/pull/30) - Add `Kind::Maybe::Typed` and the helpers `Kind::Maybe()` / `Kind::Optional()` for typed monads. They return `Some` only if the value has the expected kind.

## [2.2.0] - 2020-06-23

### Changed

- [#29](https://github.com/u-gems/kind/pull/29) - Invert the comparison with `Kind::Undefined` to avoid unexpected callbacks (e.g. `ActiveRecord::AssociationRelation#==` always performing a query).

## [2.1.0] - 2020-05-12

### Added

- [#28](https://github.com/u-gems/kind/pull/28) - Allow passing multiple arguments to `Kind.of.<Type>.instance?(*args)` and `Kind.of.<Type>?(*args)`.
- [#28](https://github.com/u-gems/kind/pull/28) - Add `Kind::Some()` and `Kind::None()` helpers.
- [#28](https://github.com/u-gems/kind/pull/28) - Add `Kind.of?(<Type>, *args)` to check if one or many values have the expected kind. With a single `<Type>` argument it returns a lambda usable as a block.

### Changed

- [#28](https://github.com/u-gems/kind/pull/28) - **BREAKING:** `Kind.of.<Type>.to_proc` now behaves like `Kind.of.<Type>.instance(value)` (returns the value or raises `Kind::Error`). For the predicate behavior, use the new `Kind.of.<Type>?` instead.

## [2.0.0] - 2020-05-07

### Added

- [#24](https://github.com/u-gems/kind/pull/24) - Improve `kind: { is: }` validation to check class/module inheritance.

### Changed

- [#24](https://github.com/u-gems/kind/pull/24) - **BREAKING:** `Kind.{of,is}.Callable` now only checks that the given object `respond_to?(:call)`.

### Removed

- [#24](https://github.com/u-gems/kind/pull/24) - Remove `kind: { is_a: }` from `Kind::Validator`.
- [#24](https://github.com/u-gems/kind/pull/24) - Remove `kind: { klass: }` from `Kind::Validator`.

## [1.9.0] - 2020-05-06

### Added

- [#23](https://github.com/u-gems/kind/pull/23) - Add `Kind.of.<Type>.to_proc` as an alias for `Kind.of.<Type>.instance?`.
- [#23](https://github.com/u-gems/kind/pull/23) - Add `Kind::Validator` (`ActiveModel` validator) as an alternative to [`type_validator`](https://github.com/u-gems/type_validator).

  ```ruby
  require 'kind/active_model/validation'

  class Person
    include ActiveModel::Validations
    attr_reader :name, :age
    validates :name, kind: { of: String }
    validates :age,  kind: { of: Integer }
    def initialize(name:, age:); @name, @age = name, age; end
  end
  ```

## [1.8.0] - 2020-05-03

### Added

- [#22](https://github.com/u-gems/kind/pull/22) - `Kind.of.<Type>.instance?` returns a lambda when called without an argument (block-friendly).
- [#22](https://github.com/u-gems/kind/pull/22) - Add `.as_optional` / `.as_maybe` on type checkers (returns a typed `Maybe`; lambda when called without arguments).

## [1.7.0] - 2020-05-03

### Fixed

- [#20](https://github.com/u-gems/kind/pull/20) - Fix the verification of modules using `Kind.is()`.

## [1.6.0] - 2020-04-17

### Added

- [#19](https://github.com/u-gems/kind/pull/19) - Add aliases to perform strict type verification on registered type checkers: `Kind.of.<Type>[value, or: ...]` and `Kind.of.<Type>.instance(value, or: ...)`.
- [#19](https://github.com/u-gems/kind/pull/19) - Add `.or_undefined` for any type checker (returns `Kind::Undefined` instead of raising).
- [#19](https://github.com/u-gems/kind/pull/19) - Allow dynamic verification of types with `Kind.of(<Type>, value)` and dynamic checker creation with `Kind.of(<Type>)` (no registration required), exposing the full type-checker API (`[]`, `instance`, `instance?`, `class?`, `or_nil`, `or_undefined`).
- [#19](https://github.com/u-gems/kind/pull/19) - Add new type checkers: `Kind::Of::Set`, `Kind::Of::Maybe`, `Kind::Of::Optional`.
- [#19](https://github.com/u-gems/kind/pull/19) - Add `Kind::Empty` with constants for frozen empty values: `Kind::Empty::SET`, `Kind::Empty::HASH`, `Kind::Empty::ARRAY`, `Kind::Empty::STRING`. When the top-level `Empty` constant is undefined, it is aliased to `Kind::Empty`.

### Changed

- [#19](https://github.com/u-gems/kind/pull/19) - Change the output of `Kind::Undefined.to_s` / `Kind::Undefined.inspect` from `"Undefined"` to `"Kind::Undefined"`.

## [1.5.0] - 2020-04-12

### Added

- [#18](https://github.com/u-gems/kind/pull/18) - Refactor `Kind::Maybe`.
- [#18](https://github.com/u-gems/kind/pull/18) - Add `Kind::Maybe::Value` module with `.some?` / `.none?` predicates for raw values.

## [1.4.0] - 2020-04-12

### Changed

- [#17](https://github.com/u-gems/kind/pull/17) - Rename `Kind::Optional` to `Kind::Maybe`. `Kind::Optional` remains available as an alias.

## [1.3.0] - 2020-04-12

### Added

- [#16](https://github.com/u-gems/kind/pull/16) - Add the special type checkers `Kind::Of::Callable` (object responds to `:call`) and `Kind::Is::Callable` (class whose `public_instance_methods.include?(:call)`).

## [1.2.0] - 2020-04-12

### Added

- [#15](https://github.com/u-gems/kind/pull/15) - Add `Kind::Optional`, the Maybe monad: encapsulates an optional value (`Some` / `None`) and short-circuits chained operations when a `nil` / `Kind::Undefined` is produced. Exposes `#map`/`#then`, `#value`, `#some?`/`#none?`, `#value_or(default | { ... })`, `#try(method, *args)`, and the `Kind::Optional[value]` constructor.
- [#15](https://github.com/u-gems/kind/pull/15) - Add `Kind::Undefined.to_s`, `Kind::Undefined.inspect`, `Kind::Undefined.clone`, `Kind::Undefined.dup`, and `Kind::Undefined.default(value, fallback)`.

## [1.1.0] - 2020-04-09

### Added

- [#14](https://github.com/u-gems/kind/pull/14) - Add `Kind::Undefined`, representing an undefined value distinct from `nil`.

### Fixed

- [#14](https://github.com/u-gems/kind/pull/14) - Raise `Kind::Error` if `nil` is the argument of any strict type checker.

## [1.0.0] - 2020-03-16

### Added

- [#12](https://github.com/u-gems/kind/pull/12) - Register type checkers respecting their namespaces, so nested classes like `Account::User::Membership` get the full `Kind.of.Account::User::Membership` API (`[]`, `instance?`, `class?`, `or_nil`, …).

## [0.6.0] - 2020-01-06

### Added

- [#11](https://github.com/u-gems/kind/pull/11) - Register the `Queue` (`Thread::Queue`) type checker: `Kind::Of::Queue`, `Kind::Is::Queue`.

## [0.5.0] - 2020-01-04

### Added

- [#4](https://github.com/u-gems/kind/pull/4) - Allow defining a default value when the verified object is `nil`: `Kind.of.Hash(nil, or: {})`.

## [0.4.0] - 2020-01-03

### Changed

- [#3](https://github.com/u-gems/kind/pull/3) - Require Ruby `>= 2.2.0` as the minimum supported version.

## [0.3.0] - 2020-01-03

### Added

- [#2](https://github.com/u-gems/kind/pull/2) - Add `Kind::Checker.new(<Type>)` for building reusable type-checker objects with `class?`, `instance?`, `or_nil`, …

### Changed

- [#2](https://github.com/u-gems/kind/pull/2) - **BREAKING:** Replace `instance_eval`-on-modules with singleton objects when defining type checkers via `Kind::Types.add()`. The behavior is unchanged, but `Kind::Of::<Type>` constants are now `Kind::Checker` objects instead of modules.

## [0.2.0] - 2020-01-02

### Added

- [#1](https://github.com/u-gems/kind/pull/1) - Register type checkers for Ruby core classes (`Symbol`, `Numeric`, `Integer`, `Float`, `Regexp`, `Time`, `Array`, `Range`, `Hash`, `Struct`, `Enumerator`, `Method`, `Proc`, `IO`, `File`) and modules (`Enumerable`, `Comparable`).
- [#1](https://github.com/u-gems/kind/pull/1) - Add the special type checkers `Kind::Of::Boolean` (`true`/`false`), `Kind::Of::Lambda`, and `Kind::Of::Module`.

## [0.1.0] - 2019-12-26

### Added

- Require Ruby `>= 2.3.0` as the minimum supported version.
- `Kind::Error` for type-checker errors.
- `Kind::Of.call(<Type>, value)` — returns the value if it is a kind of `<Type>`, raises `Kind::Error` otherwise. `Kind::Of::Class()` checks the given object is a class.
- `Kind::Is.call(<Type>, other)` — checks the first kind is equal to or a parent of the second.
- Shortcuts `Kind.of` (→ `Kind::Of`) and `Kind.is` (→ `Kind::Is`).
- `Kind::Types.add(<Type>)` for registering new type checkers. Registration adds `Kind.of.<Type>(value)` / `Kind.is.<Type>(other)` methods and a `Kind::Of::<Type>` module exposing `class?`, `instance?`, `or_nil`.
- Register the `String` and `Hash` type checkers: `Kind::Of::Hash` / `Kind::Is::Hash`, `Kind::Of::String` / `Kind::Is::String`.

[6.0.1]: https://github.com/u-gems/kind/compare/v6.0.0...v6.0.1
[6.0.0]: https://github.com/u-gems/kind/compare/v5.10.0...v6.0.0
[5.10.0]: https://github.com/u-gems/kind/compare/v5.9.0...v5.10.0
[5.9.0]: https://github.com/u-gems/kind/compare/v5.8.1...v5.9.0
[5.8.1]: https://github.com/u-gems/kind/compare/v5.8.0...v5.8.1
[5.8.0]: https://github.com/u-gems/kind/compare/v5.7.0...v5.8.0
[5.7.0]: https://github.com/u-gems/kind/compare/v5.6.0...v5.7.0
[5.6.0]: https://github.com/u-gems/kind/compare/v5.5.0...v5.6.0
[5.5.0]: https://github.com/u-gems/kind/compare/v5.4.1...v5.5.0
[5.4.1]: https://github.com/u-gems/kind/compare/v5.4.0...v5.4.1
[5.4.0]: https://github.com/u-gems/kind/compare/v5.3.0...v5.4.0
[5.3.0]: https://github.com/u-gems/kind/compare/v5.2.0...v5.3.0
[5.2.0]: https://github.com/u-gems/kind/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/u-gems/kind/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/u-gems/kind/compare/v4.1.0...v5.0.0
[4.1.0]: https://github.com/u-gems/kind/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/u-gems/kind/compare/v3.1.0...v4.0.0
[3.1.0]: https://github.com/u-gems/kind/compare/v3.0.1...v3.1.0
[3.0.1]: https://github.com/u-gems/kind/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/u-gems/kind/compare/v2.3.0...v3.0.0
[2.3.0]: https://github.com/u-gems/kind/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/u-gems/kind/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/u-gems/kind/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/u-gems/kind/compare/v1.9.0...v2.0.0
[1.9.0]: https://github.com/u-gems/kind/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/u-gems/kind/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/u-gems/kind/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/u-gems/kind/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/u-gems/kind/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/u-gems/kind/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/u-gems/kind/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/u-gems/kind/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/u-gems/kind/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/u-gems/kind/compare/v0.6.0...v1.0.0
[0.6.0]: https://github.com/u-gems/kind/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/u-gems/kind/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/u-gems/kind/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/u-gems/kind/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/u-gems/kind/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/u-gems/kind/releases/tag/v0.1.0
