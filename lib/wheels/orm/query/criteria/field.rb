module Wheels
  module Orm
    class Query
      class Criteria
        class Field

          def initialize(criteria, field)
            @criteria = criteria
            @field = field
            @direction = :asc
          end

          def field
            @field
          end

          def eq(value)
            @criteria.merge(Wheels::Orm::Query::Condition::eq(@field, value))
          end

          def lt(value)
            @criteria.merge(Wheels::Orm::Query::Condition::lt(@field, value))
          end

          def gt(value)
            @criteria.merge(Wheels::Orm::Query::Condition::gt(@field, value))
          end
          
          def desc
            @direction = :desc
            self
          end
          
          def asc
            @direction = :asc
            self
          end
          
          def direction
            @direction
          end

        end # class Field
      end # class Criteria
    end # class Query
  end # module Orm
end # module Wheels