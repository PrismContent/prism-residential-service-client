module ResidentialService
  class OfficeHour
    require File.expand_path(File.dirname(__FILE__), 'office_hour_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    @@attributes = [:purpose, :recurrence, :ordinals, :weeks_of_month, :starting_on, :ending_on, 
                    :starting_at, :ending_at, :account_id, :id]

    attr_accessor *@@attributes

    validates_presence_of :purpose, :recurrence, :account_id

    class << self
      def model_name
        'OfficeHour'
      end

      def find(account_id, office_hour_id = nil)
        ResidentialService::OfficeHourPersistence.find_for_account account_id, office_hour_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|office_hour| office_hour.destroy }
      end
    end

    def initialize(office_hour_attr={})
      office_hour_attr = HashWithIndifferentAccess.new(office_hour_attr ||{})
      self.attributes = office_hour_attr.slice *@@attributes

      cast_to_date :starting_on, :ending_on
      cast_to_time :starting_at, :ending_at
    end

    def new_record?
      self.id.blank?
    end

    def save
      ResidentialService::OfficeHourPersistence.save self
    end

    def destroy
      ResidentialService::OfficeHourPersistence.destroy self
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

      def cast_to_time(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_time
          end
        end
      end

      def cast_to_date(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_date
          end
        end
      end
  end
end
