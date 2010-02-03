module Clipper
  class Query
    module Arel
      class Engine
        def initialize(repository)
          raise ArgumentError.new unless repository.is_a?(Clipper::Repository)

          @repository = repository
        end

        def adapter_name
          # TODO: this is ugly
          case @repository
          when Clipper::Repositories::Abstract
            'Abstract'
          when Clipper::Repositories::Jdbc::Hsqldb
            'HSQLDB'
          when Clipper::Repositories::Jdbc::Mysql
            'MySQL'
          when Clipper::Repositories::Jdbc::Sqlite
            'SQLite'
          else
            raise "Repsitory type not supported #{@repository.inspect}"
          end
        end

        def quote_table_name(name)
          @repository.quote_identifier(name)
        end

        def quote_column_name(name)
          @repository.quote_identifier(name)
        end

        def quote_string(s)
          s.gsub(/\\/, '\&\&').gsub(/'/, "''")
        end

        def quote(value, column)
          case value
          when String
            "'#{quote_string(value)}'"
          when NilClass then "NULL"
          when TrueClass then '1'
          when FalseClass then '0'
          when Float, Fixnum, Bignum then value.to_s
          else
            raise "Unknown type (#{value.class})."
          end
        end
      end
    end
  end
end
