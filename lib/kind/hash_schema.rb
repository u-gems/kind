# frozen_string_literal: true

require 'kind/basic'
require 'kind/objects'

class Kind::HashSchema
  require 'kind/hash_schema/filter'

  attr_reader :spec

  def initialize(*args)
    @spec = args.flatten
  end

  def filter(arg)
    input = Kind.of(::Hash, arg)

    Filter.(@spec, input, {})
  end
end
