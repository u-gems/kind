# frozen_string_literal: true

require 'kind/empty'

class Kind::HashSchema
  SliceHash = ->(hash, keys) do
    return hash.slice(*keys) if hash.respond_to?(:slice)

    hash.select { |key, _value| keys.include?(key) }
  end

  module Filter
    extend self

    def call(filters, input, output)
      filters.each do |filter|
        case filter
        when Hash then hash_filter(output, filter, input)
        when Symbol, String then scalar_filter(output, filter, input)
        end
      end

      output
    end

    def scalar_filter(output, filter_key, input)
      if input.has_key?(filter_key) && IsPermittedScalar.(input[filter_key])
        output[filter_key] = input[filter_key]
      end
    end

    IsPermittedScalar = ->(value) do
      case value
      when String, Symbol, NilClass, Numeric, TrueClass, FalseClass, Date, Time, StringIO, IO
        true
      else
        false
      end
    end

    IsNonScalar = ->(value) do
      value.is_a?(Array) || value.is_a?(Hash)
    end

    def hash_filter(output, filter, input)
      SliceHash.(input, filter.keys).each do |key, value|
        next unless value
        next unless input.has_key?(key)

        filter_spec = filter[key]

        if filter_spec == Kind::Empty::ARRAY
          # Declaration { comment_ids: [] }.

          output[key] = (ary = input[key]).is_a?(Array) ? ary.select(&IsPermittedScalar) : []
        elsif IsNonScalar.(value)
          case filter_spec
          when ::Module, ::Proc, Kind::BasicObject
            # Declaration { users: Array } or { users: Kind::Array } or { users: ->{} }.

            output[key] = input[key] if filter_spec === value
          else
            if filter_spec.is_a?(::Array) && filter_spec.size == 1
              expected = filter_spec[0]

              case expected
              when ::Module, ::Proc, Kind::BasicObject
                # Declaration { users: Array(String) } or { users: [Kind::String] } or { users: [->{}] }.

                output[key] = input[key].select { |item| expected === item }
              when ::Symbol, ::String
                # Declaration { users: [:name] } or { users: ['name'] }.

                output[key] = input[key].map do |item|
                  (val = item[expected]) && IsPermittedScalar.(val) ? {expected => val} : {}
                end
              when Hash
                # Declaration { user: [ name: Array ] }.

                output[key] = each_element(value) { |element| call(Array(filter_spec), element, {}) }
              else
                raise NotImplementedError
              end
            else
              case filter_spec
              when Hash
                # Declaration { name: String }.

                output[key] = hash_filter({}, filter_spec, input[key])
              else
                # Declaration [:name, :age, { address: ... }].

                output[key] = each_element(value) { |element| call(Array(filter_spec), element, {}) }
              end
            end
          end
        else
          case filter_spec
          when ::Module, ::Proc, Kind::BasicObject
            # Declaration { users: Array } or { users: Kind::Array } or { users: ->{} }.

            output[key] = input[key] if filter_spec === value
          end
        end
      end
    end

    IsNestedAttribute = ->(key, value) do # :nodoc:
      /\A-?\d+\z/ =~ key.to_s && value.is_a?(Hash)
    end

    def each_element(object, &block)
      case object
      when Array then object.grep(Hash).map { |el| yield el }.compact
      when Hash
        return yield(object) unless object.any? { |k, v| IsNestedAttribute.(k, v) }

        each_nested_attribute(object, &block)
      end
    end

    def each_nested_attribute(object)
      hash = {}

      object.each { |k, v| hash[k] = yield(v) if IsNestedAttribute.(k, v) }

      hash
    end
  end
end
