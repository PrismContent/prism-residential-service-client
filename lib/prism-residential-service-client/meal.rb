module ResidentialService
  class Meal < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'meal_type_course_persistence')

    self.attribute_names = {
      :account_id => Integer, :name => String, :description => String, :starting_at => Time, 
      :ending_at => Time, :served_on => Date, :meal_type_course_id => Integer, :id => Integer, 
      :position => Integer, :meal_type_name => String
    }

    validates_presence_of :name, :meal_type_course_id
    class << self
      def find(account_id, meal_type_course_id = nil)
        ResidentialService::MealPersistence.find_for_account_id account_id, meal_type_course_id
      end
    end

    def initialize(meal_attr={})
      super
      cast_to_date :served_on
      cast_to_time :starting_at, :ending_at
    end

    def save
      self.served_on ||= self.starting_at.to_date if self.starting_at
      self.served_on ||= self.ending_at.to_date if self.ending_at

      ResidentialService::MealPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::MealPersistence.destroy self
    end

    def reload
      instance = self.class.find(self.meal_type_id, self.id)
      self.attributes = instance.attributes
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
