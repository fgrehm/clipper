module Clipper
  class Query
    module Arel
      class Entity < ::Arel::Relation
        delegate :to_sql, :attributes, :to => :table

        def initialize(mapping)
          raise ArgumentError.new unless mapping.is_a?(Clipper::Mapping)

          fields = mapping.fields.collect { |f| ::Arel::Attribute.new(self, f.name) }
          @table = Table(mapping.name)

          #   Remove ActiveRecord dependency by avoiding the need to check database
          # table for columns
          @table.instance_variable_set('@attributes', fields)
        end

        def table
          @table
        end
      end
    end
  end
end
