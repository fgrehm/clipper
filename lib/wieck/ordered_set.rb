require "set"

module Wieck
  class OrderedSet

    include Enumerable

    def initialize(*values)
      @values = values.dup
    end

    def <<(value)
      if !@values.include?(value)
        @values << value
      else
        nil
      end
    end

    def each
      @values.each do |value|
        yield value
      end
    end

    def concat(*values)
      @values.concat(*values)
    end

    def empty?
      @values.empty?
    end

  end
end