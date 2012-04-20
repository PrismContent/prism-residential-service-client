module ResidentialService
  class MealTypeCourse
    require File.expand_path(File.dirname(__FILE__), 'meal_type_course_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:name, :position, :meal_type_name, :meal_type_id, :id]

    validates_presence_of :name, :meal_type_id
    attr_accessor *@@attributes
    attr_accessor :account_id

    class << self
      def find(meal_type_id, meal_type_course_id = nil)
        ResidentialService::MealTypeCoursePersistence.find_for_meal_type meal_type_id, meal_type_course_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end
    end

    def initialize(meal_attr={})
      meal_attr ||= {}
      meal_attr = ActiveSupport::HashWithIndifferentAccess.new(meal_attr)
      self.attributes = meal_attr.slice *@@attributes
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::MealTypeCoursePersistence.save self
    end

    def destroy
      ResidentialService::MealTypeCoursePersistence.destroy self
    end

    def reload
      instance = self.class.find(self.meal_type_id, self.id)
      self.attributes = instance.attributes
    end

    def move(direction)
      raise(ArgumentError, 'Direction must be higher, lower, top, or bottom.') unless [:higher, :lower, :top, :bottom].include?(direction)
      ResidentialService::MealTypeCoursePersistence.move self, direction
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

    def meal_type=(meal_type)
      raise(ArgumentError, "Expected a MealType") unless meal_type.is_a?(ResidentialService::MealType)
      send('meal_type_id='.to_sym, meal_type.id)
      @meal_type = meal_type
    end

    def meal_type
      @meal_type ||= ResidentialService::MealType.find(self.account_id, self.meal_type_id)
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
