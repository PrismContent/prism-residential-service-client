module ResidentialService
  class Resident
    require File.expand_path(File.dirname(__FILE__), 'resident_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:first_name, :last_name, :spouse_name, :spouse_id, 
                    :born_on, :email, :account_id, :id]

    attr_accessor *@@attributes

    validates_presence_of :first_name, :last_name, :account_id

    class << self
      def find(account_id, resident_id = nil)
        ResidentialService::ResidentPersistence.find_for_account account_id, resident_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end
    end

    def initialize(resident_attr={})
      resident_attr = HashWithIndifferentAccess.new(resident_attr ||{})
      self.attributes = resident_attr.slice *@@attributes
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::ResidentPersistence.save self
    end

    def destroy
      ResidentialService::ResidentPersistence.destroy self
    end

    def to_param
      send(:id).to_s
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
