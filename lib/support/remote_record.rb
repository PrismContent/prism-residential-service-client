require 'active_support/core_ext/class/attribute'

module Prism
  require File.join(File.dirname(__FILE__), 'serializers.rb')
  require File.join(File.dirname(__FILE__), 'validation.rb')

  class RemoteRecord
    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if Object.const_defined?('ActiveModel')

    class_attribute :attribute_names

    class << self

      def create(attr={})
        instance = new(attr)
        instance.save
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|instance| instance.destroy }
      end
    end

    def initialize(attr={})
      self.attributes = HashWithIndifferentAccess.new(attr ||{})
    end

    def new_record?
      self.id.blank?
    end

    def update_attributes(attrs={})
      self.attributes = attrs
      save
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
    end

    def attributes
      self.class.attribute_names.keys.inject(HashWithIndifferentAccess.new) do |attrs, key|
        attrs.merge key => read_attribute_for_validation(key)
      end
    end

    def attributes=(attrs)
      multi_parameter_attributes  = []

      attrs.each_pair do |k,v| 
        if k.to_s.include?("(")
          multi_parameter_attributes << [ k, v ]
        else
          send "#{k}=", v if self.class.attribute_names.keys.include?(k.to_sym)
        end
      end

      assign_multiparameter_attributes(multi_parameter_attributes) unless multi_parameter_attributes.empty?
    end

    def read_attribute_for_validation(key)
      send key
    end
    
    def service_errors
      @service_errors ||= {}
    end

    def method_missing(meth, *args, &block)
      case
        when self.class.attribute_names.keys.include?(meth) 
        when meth.to_s =~ /=/ && self.class.attribute_names.keys.include?(meth.to_s[0..-2].to_sym)
          self.class.set_attribute_accessors
          self.send(meth, *args)
        else
          super
      end
    end

    private
      class << self
        def set_attribute_accessors
          attr_accessor *(self.attribute_names.keys)
        end
      end

      def service_errors=(errors)
        @service_errors = errors
      end      

      #
      # The following code was adapted from Rails' ActiveRecord::Base class
      # for assigning multiparameter attributes like Date and Time fields from
      # the date_select/time_select fields rendered by a Rails form
      #
      # April 5, 2013
      #
      # see: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/attribute_assignment.rb
      #
      def assign_multiparameter_attributes(pairs)
        execute_callstack_for_multiparameter_attributes(
          extract_callstack_for_multiparameter_attributes(pairs)
        )
      end

      def execute_callstack_for_multiparameter_attributes(callstack)
        errors = []
        callstack.each do |name, values_with_empty_parameters|
          begin
            send("#{name}=", MultiparameterAttribute.new(self, name, values_with_empty_parameters).read_value)
          rescue => ex
            err = "error on assignment #{values_with_empty_parameters.values.inspect} to #{name} (#{ex.message})" % [ex, name]
            errors << ArgumentError.new(err)
          end
        end

        unless errors.empty?
          error_descriptions = errors.map { |ex| ex.message }.join(",")
          raise ArgumentError.new "#{errors.size} error(s) on assignment of multiparameter attributes [#{error_descriptions}]"
        end
      end

      def extract_callstack_for_multiparameter_attributes(pairs)
        attributes = {}

        pairs.each do |(multiparameter_name, value)|
          attribute_name = multiparameter_name.split("(").first
          attributes[attribute_name] ||= {}

          parameter_value = value.blank? ? nil : type_cast_attribute_value(multiparameter_name, value)
          attributes[attribute_name][find_parameter_position(multiparameter_name)] ||= parameter_value
        end

        attributes
      end

      def type_cast_attribute_value(multiparameter_name, value)
        multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
      end
      
      def find_parameter_position(multiparameter_name)
        multiparameter_name.scan(/\(([0-9]*).*\)/).first.first.to_i
      end
 
      def cast_to_time(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_time.in_time_zone
          end
        end
      end

      def cast_to_date(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_date
          end
        end
      end
    end

    class MultiparameterAttribute #:nodoc:
      attr_reader :object, :name, :values, :column

      def initialize(object, name, values)
        @object = object
        @name   = name
        @values = values
      end

      def read_value
        return if values.values.compact.empty?

        klass = object.class.attribute_names[name.to_sym]
        if klass == Time
          read_time
        elsif klass == Date
          read_date
        else
          read_other(klass)
        end
      end

      private

      def instantiate_time_object(set_values)
        Time.local(*set_values).in_time_zone
      end

      def read_time
        { 1 => 1970, 2 => 1, 3 => 1 }.each do |key,value|
          values[key] ||= value
        end

        max_position = extract_max_param(6)
        set_values   = values.values_at(*(1..max_position))
        # If Time bits are not there, then default to 0
        (3..5).each { |i| set_values[i] = set_values[i].presence || 0 }
        instantiate_time_object(set_values)
      end

      def read_date
        return if blank_date_parameter?
        set_values = values.values_at(1,2,3)
        begin
          Date.new(*set_values)
        rescue ArgumentError # if Date.new raises an exception on an invalid date
          instantiate_time_object(set_values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
        end
      end

      def read_other(klass)
        max_position = extract_max_param
        positions    = (1..max_position)
        validate_required_parameters!(positions)

        set_values = values.values_at(*positions)
        klass.new(*set_values)
      end

      # Checks whether some blank date parameter exists. Note that this is different
      # than the validate_required_parameters! method, since it just checks for blank
      # positions instead of missing ones, and does not raise in case one blank position
      # exists. The caller is responsible to handle the case of this returning true.
      def blank_date_parameter?
        (1..3).any? { |position| values[position].blank? }
      end

      # If some position is not provided, it errors out a missing parameter exception.
      def validate_required_parameters!(positions)
        if missing_parameter = positions.detect { |position| !values.key?(position) }
          raise ArgumentError.new("Missing Parameter - #{name}(#{missing_parameter})")
        end
      end

      def extract_max_param(upper_cap = 100)
        [values.keys.max, upper_cap].min
      end
    end
end
