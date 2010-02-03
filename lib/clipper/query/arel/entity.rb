module Clipper
  class Query
    module Arel
      class Column
        attr_reader :name, :type

        def initialize(name, type)
          @name, @type = name.to_s, type
        end
      end

      class Entity < ::Arel::Relation
        delegate :to_sql, :attributes, :where, :to => :table

        def initialize(mapping)
          raise ArgumentError.new unless mapping.is_a?(Clipper::Mapping)

          @table = Table(mapping.name)
          @engine = ::Arel::Table.engine

          # Remove ActiveRecord dependency
          columns = mapping.fields.collect { |f| Column.new(f.name, f.type) }
          @table.instance_variable_set('@columns', columns)
        end

        def engine
          @engine
        end

        def table
          @table
        end
      end
    end
  end
end
