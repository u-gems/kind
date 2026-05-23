# frozen_string_literal: true

module Kind
  class Any
    FilledList = ->(val) {(val.is_a?(::Array) || val.is_a?(::Set)) && !val.empty?}

    singleton_class.send(:alias_method, :[], :new)

    attr_reader :values

    def initialize(*args)
      array = args.size == 1 ? args[0] : args

      @values = Kind.of(FilledList, array, expected: 'filled array or set')
    end

    def ===(value)
      @values.include?(value)
    end

    def [](value, label: nil)
      STRICT.object_is_a(self, value, label)
    end

    def |(another_kind)
      UnionType[self] | another_kind
    end

    def name
      str =
        if @values.is_a?(::Set)
          "{#{@values.to_a.map(&:inspect).join(', ')}}"
        else
          @values.inspect
        end

      "Kind::Any#{str}"
    end

    alias inspect name

    private_constant :FilledList
  end
end
