module ResidentialService
  class MealType
    require File.expand_path(File.dirname(__FILE__), 'meal_type_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:name, :begins_at, :ends_at, :account_id, :id]

    validates_presence_of :name, :begins_at, :ends_at, :account_id
    attr_accessor *@@attributes

    def begins_at=(val)
      @begins_at = val.is_a?(Time) ? val : val.to_time
    end

    def ends_at=(val)
      @ends_at = val.is_a?(Time) ? val : val.to_time
    end

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
      meal_attr = HashWithIndifferentAccess.new(meal_attr ||{})
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

    def to_param
      send :id
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
