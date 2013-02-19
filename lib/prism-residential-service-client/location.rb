module ResidentialService
  class Location
    require File.expand_path(File.dirname(__FILE__), 'location_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if ActiveModel::Naming

    @@attributes = [:name, :code, :account_id, :id]
    attr_accessor *@@attributes

    validates_presence_of :name, :account_id

    class << self
      def find(account_id, location_id = nil)
        ResidentialService::LocationPersistence.find_for_account account_id, location_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|location| location.destroy }
      end
    end

    def initialize(location_attr={})
      location_attr = HashWithIndifferentAccess.new(location_attr ||{})
      self.attributes = location_attr.slice *@@attributes
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::LocationPersistence.save self
    end

    def destroy
      ResidentialService::LocationPersistence.destroy self
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
    end

    def attributes
      @@attributes.inject(HashWithIndifferentAccess.new) do |attrs, key|
        attrs.merge key => read_attribute_for_validation(key)
      end
    end

    def attributes=(attrs)
      attrs.each_pair{|k,v| send "#{k}=", v}
    end

    def read_attribute_for_validation(key)
      send key
    end

    private
      def service_errors=(errors)
        @service_errors = errors
      end

      def service_errors
        @service_errors ||= {}
      end
  end
end
