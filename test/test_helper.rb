require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  add_filter '/lib/kind/active_model/validation.rb'

  enable_coverage :branch
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'kind' if ENV.fetch('KIND_BASIC', '').empty?

active_model_version = ENV.fetch('ACTIVEMODEL_VERSION', '7.0.0')

if active_model_version < '7.0.0'
  require 'kind/active_model/validation'
end

require_relative 'support/kind_is_test'
require_relative 'support/step_adapter_assertions'

require 'minitest/pride'
require 'minitest/autorun'

class Minitest::Test
  def assert_raises_with_message(exception, msg, &block)
    block.call
  rescue exception => e
    String === msg ? assert_equal(msg, e.message) : assert_match(msg, e.message)
  else
    raise "Expected to raise #{exception} w/ message #{msg}, none raised"
  end

  def assert_raises_kind_error(arg, &block)
    msg =
      case arg
      when String, Regexp then arg
      when Hash then "#{arg.fetch(:given)} expected to be a kind of #{arg.fetch(:expected)}"
      else raise ArgumentError, 'argument must be a string, regexp or hash'
      end

    assert_raises_with_message(Kind::Error, msg, &block)
  end

  def assert_kind_undefined(object)
    assert_equal(Kind::Undefined, object)
  end
end
