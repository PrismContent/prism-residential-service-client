module ResidentialService
  class MealTypeCourse < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'meal_type_course_persistence')

    self.attribute_names = {
      :name => String, :position => Integer, :meal_type_name => String, 
      :meal_type_id => Integer, :id => Integer
    }

    validates_presence_of :name, :meal_type_id
    attr_accessor :account_id

    class << self
      def find(meal_type_id, meal_type_course_id = nil)
        ResidentialService::MealTypeCoursePersistence.find_for_meal_type meal_type_id, meal_type_course_id
      end
    end

    def save
      ResidentialService::MealTypeCoursePersistence.save(self) if valid?
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

    def meal_type=(meal_type)
      raise(ArgumentError, "Expected a MealType") unless meal_type.is_a?(ResidentialService::MealType)
      send('meal_type_id='.to_sym, meal_type.id)
      @meal_type = meal_type
    end

    def meal_type
      @meal_type ||= ResidentialService::MealType.find(self.account_id, self.meal_type_id)
    end
  end
end
