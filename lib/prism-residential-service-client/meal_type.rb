module ResidentialService
  class MealType < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'meal_type_persistence')

    self.attribute_names = {
      :name => String, :begins_at => Time, :ends_at => Time,
      :account_id => Integer, :id => Integer, :course_names => String
    }

    validates_presence_of :name, :begins_at, :ends_at, :account_id

    class << self
      def find(account_id, meal_type_id = nil)
        ResidentialService::MealTypePersistence.find_for_account account_id, meal_type_id
      end
    end

    def initialize(meal_attr={})
      super
      cast_to_time :begins_at, :ends_at
    end

    def save
      ResidentialService::MealTypePersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::MealTypePersistence.destroy self
    end
  end
end
