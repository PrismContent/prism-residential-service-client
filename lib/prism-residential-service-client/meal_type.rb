module ResidentialService
  class MealType
    require File.expand_path(File.dirname(__FILE__), 'meal_type_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:name, :begins_at, :ends_at, :account_id, :id]

    validates_presence_of :name, :begins_at, :ends_at, :account_id
    attr_accessor *@@attributes

    class << self
      def find(account_id, meal_type_id = nil)
        ResidentialService::MealTypePersistence.find_for_account account_id, meal_type_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end
    end

    def initialize(meal_attr={})
      meal_attr = ActiveSupport::HashWithIndifferentAccess.new(meal_attr ||{})
      self.attributes = meal_attr.slice *@@attributes
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::MealTypePersistence.save self
    end

    def destroy
      ResidentialService::MealTypePersistence.destroy self
    end

    def attributes
      @@attributes.inject(ActiveSupport::HashWithIndifferentAccess.new) do |attrs, key|
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
