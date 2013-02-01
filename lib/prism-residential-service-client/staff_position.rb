module ResidentialService
  class StaffPosition
    require File.expand_path(File.dirname(__FILE__), 'staff_position_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:name, :name, :sortable, :position, :account_id, :id]
    attr_accessor *@@attributes

    validates_presence_of :name, :account_id

    class << self
      def find(account_id, staff_position_id = nil)
        ResidentialService::StaffPositionPersistence.find_for_account account_id, staff_position_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end
    end

    def initialize(staff_position_attr={})
      staff_position_attr = HashWithIndifferentAccess.new(staff_position_attr ||{})
      self.attributes = staff_position_attr.slice *@@attributes
    end

    def sortable?
      !!attributes[:sortable]
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::StaffPositionPersistence.save self
    end

    def destroy
      ResidentialService::StaffPositionPersistence.destroy self
    end

    def move(direction)
      ResidentialService::StaffPositionPersistence.move self, direction
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
