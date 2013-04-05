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
      instance_attr = HashWithIndifferentAccess.new(attr ||{})
      self.attributes = instance_attr.slice *self.class.attribute_names
    end

    def new_record?
      self.id.blank?
    end

    def update_attributes(attr={})
      attr.keys.each do |attr_id|
        self.send("#{attr_id}=", attr[attr_id])
      end
      save
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
    end

    def attributes
      self.class.attribute_names.inject(HashWithIndifferentAccess.new) do |attrs, key|
        attrs.merge key => read_attribute_for_validation(key)
      end
    end

    def attributes=(attrs)
      attrs.each_pair{|k,v| send "#{k}=", v}
    end

    def read_attribute_for_validation(key)
      send key
    end
    
    def service_errors
      @service_errors ||= {}
    end

    def method_missing(meth, *args, &block)
      case
        when self.class.attribute_names.include?(meth) 
        when meth.to_s =~ /=/ && self.class.attribute_names.include?(meth.to_s[0..-2].to_sym)
          self.class.set_attribute_accessors
          self.send(meth, *args)
        else
          super
      end
    end

    private
      class << self
        def set_attribute_accessors
          attr_accessor *(self.attribute_names)
        end
      end

      def service_errors=(errors)
        @service_errors = errors
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
end
