module Wheels
  module Orm
    module Validations
      
      class FormatValidator
        def initialize(field, format, message = "%1$s is not formatted properly.")
          @field = field
          @format = format
          @message = message
        end
        
        def call(instance, errors)
          unless instance.send(@field) =~ @format
            errors.append(instance, @message % [@field], @field)
          end
        end
      end
      
    end # module Validations
  end # module Orm
end # module Wheels