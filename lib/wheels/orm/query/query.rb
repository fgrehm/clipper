module Wheels
  module Orm
    class Query
      def initialize(mapping, conditions = nil)
        @mapping = mapping
        @conditions = conditions
      end

      def mapping
        @mapping
      end

      def conditions
        @conditions
      end

      def paramaters
        case @conditions
        when nil then []
        when Condition then [@conditions.value]
        else
          begin
            @conditions.values.map { |condition| condition.value }
          rescue NoMethodError => nme
            p @conditions
            raise
          end
        end
      end

      def fields
        case @conditions
        when nil then []
        when Condition then [@conditions.field]
        else
          @conditions.values.map { |condition| condition.field }
        end
      end
    end
  end
end