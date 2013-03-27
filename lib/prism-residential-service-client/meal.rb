module ResidentialService
  class Meal
    require File.expand_path(File.dirname(__FILE__), 'meal_type_course_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if Object.const_defined?('ActiveModel')

    @@attributes = [:account_id, :name, :description, :starting_at, :ending_at, :served_on, :meal_type_course_id, :id, :position, :meal_type_name]

    validates_presence_of :name, :meal_type_course_id
    attr_accessor *@@attributes

    def starting_at=(val)
      @starting_at = val.is_a?(Time) ? val : val.to_time
    end

    def ending_at=(val)
      @ending_at = val.is_a?(Time) ? val : val.to_time
    end

    def served_on=(val)
      @served_on = val.is_a?(Date) ? val : val.to_date
    end

    class << self
      def find(account_id, meal_type_course_id = nil)
        ResidentialService::MealPersistence.find_for_account_id account_id, meal_type_course_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save
        instance
      end
    end

    def initialize(meal_attr={})
      meal_attr ||= {}
      meal_attr = HashWithIndifferentAccess.new(meal_attr)

      meal_attr.merge!(:starting_at => Time.parse(meal_attr[:starting_at])) if meal_attr[:starting_at].is_a?(String)
      meal_attr.merge!(:ending_at => Time.parse(meal_attr[:ending_at])) if meal_attr[:ending_at].is_a?(String)

      meal_attr[:served_on] ||= meal_attr[:starting_at].to_date if meal_attr[:starting_at]
      meal_attr[:served_on] ||= meal_attr[:ending_at].to_date if meal_attr[:ending_at]

      self.attributes = meal_attr.slice *@@attributes
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

    def save
      self.served_on ||= self.starting_at.to_date if self.starting_at
      self.served_on ||= self.ending_at.to_date if self.ending_at

      ResidentialService::MealPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::MealPersistence.destroy self
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
    end

    def reload
      instance = self.class.find(self.meal_type_id, self.id)
      self.attributes = instance.attributes
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

    def meal_type=(meal_type)
      raise(ArgumentError, "Expected a MealType") unless meal_type.is_a?(ResidentialService::MealType)
      send('meal_type_id='.to_sym, meal_type.id)
      @meal_type = meal_type
    end

    def meal_type
      @meal_type ||= ResidentialService::MealType.find(self.account_id, self.meal_type_id)
    end

    def service_errors
      @service_errors ||= {}
    end
    
    private
      def service_errors=(errors)
        @service_errors = errors
      end      
  end
end
