module Prism
  module Validation
    module ClassMethods
      def validators
        @validators ||= []
      end

      def validates_presence_of(*attribute_ids)
        attribute_ids.each do |attr_id|
          validators.push Validation::PresenceValidator.new(attr_id)       
        end
      end
    end

    module InstanceMethods
      def instance_errors
        return errors if !valid?
        service_errors
      end

      def valid?
        clear_errors
        
        # always use ResidentialService if/when inherited later
        klass = "residential_service/#{self.class.to_s.demodulize.underscore}".camelize.constantize

        klass.validators.each do |validator|
          validator.valid? self
        end

        errors.empty?        
      end

      def errors
        @errors ||= { }
      end

      def clear_errors
        @errors = { }
      end

      def add_error(attribute_id, error)
        errors[attribute_id] ||= []
        errors[attribute_id].push error
      end
    end

    class PresenceValidator
      def initialize(attribute_id, message = nil)
        @attribute_id = attribute_id
        @message = message || "#{attribute_id} must be provided".titleize
      end

      def valid?(instance)
        val = instance.send(@attribute_id)

        case
          when val.is_a?(String) && !(val == '')
            return true
          when !val.nil?
            return true
          else
            instance.add_error @attribute_id, @message
            return false
        end
      end
    end
  end
end
