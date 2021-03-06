module Clipper
  module Validations
    
    class RequiredValidator < Validator
      def initialize(field)
        @field = field
      end
      
      def call(instance, errors)
        if instance.send(@field).blank?
          errors.append(instance, "%1$s is required." % [@field], @field)
        end
      end
    end
    
  end # module Validations
end # module Clipper