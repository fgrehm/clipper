module Wheels
  module Orm
    class Mappings
      class UnmappedClassError < StandardError
      end

      class UnsupportedTypeError < StandardError
        def initialize(type)
          super("#{type.inspect} is not a registered Wheels::Orm::Type (#{Wheels::Orm::Types.inspect})")
        end
      end

      include Enumerable

      class << self
        def [](repository_name)
          @repository_mappings ||= {}
          @repository_mappings[repository_name] ||= Mappings.new
        end
      end

      def initialize
        @mappings = {}
      end

      def [](mapped_class)
        @mappings[mapped_class] || raise(UnmappedClassError.new("Mappings#[#{mapped_class}] is not mapped."))
      end

      def <<(mapping)
        raise ArgumentError.new("Mappings#<< must be passed a Mapping") unless mapping.is_a?(Wheels::Orm::Mappings::Mapping)
        @mappings[mapping.target] = mapping
      end

      def each
        @mappings.values.each { |mapping| yield mapping }
      end

      def map(target, mapped_name)
        mapping = Wheels::Orm::Mappings::Mapping.new(self, target, mapped_name)
        yield mapping
        self << mapping
        mapping
      end

    end
  end
end