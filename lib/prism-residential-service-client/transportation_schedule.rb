module ResidentialService
  class TransportationSchedule
    require File.expand_path(File.dirname(__FILE__), 'transportation_schedule_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if ActiveModel::Naming

    @@attributes = [:destination, :recurrence, :ordinals, :weeks_of_month, :starting_on, :ending_on, 
                    :starting_at, :ending_at, :account_id, :id]

    attr_accessor *@@attributes

    validates_presence_of :destination, :recurrence, :account_id

    class << self
      def find(account_id, transportation_schedule_id = nil)
        ResidentialService::TransportationSchedulePersistence.find_for_account account_id, transportation_schedule_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|transportation_schedule| transportation_schedule.destroy }
      end
    end

    def initialize(transportation_schedule_attr={})
      transportation_schedule_attr = HashWithIndifferentAccess.new(transportation_schedule_attr ||{})
      self.attributes = transportation_schedule_attr.slice *@@attributes

      cast_to_date :starting_on, :ending_on
      cast_to_time :starting_at, :ending_at
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
      ResidentialService::TransportationSchedulePersistence.save self
    end

    def destroy
      ResidentialService::TransportationSchedulePersistence.destroy self
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
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

    def service_errors
      @service_errors ||= {}
    end

    private
      def service_errors=(errors)
        @service_errors = errors
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
