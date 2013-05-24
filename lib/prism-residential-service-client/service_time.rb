module ResidentialService
  class ServiceTime < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'service_time_persistence')

    self.attribute_names = {
      :id => Integer, :service_offering_id => Integer, 
      :wday => Integer, :time_of_day => String, :starting_at => Time, :ending_at => Time
    }

    validates_presence_of :wday, :time_of_day

    class << self
      def find(service_offering_id, service_time_id = nil)
        ResidentialService::ServiceTimePersistence.find_for_service_offering service_offering_id, service_time_id
      end
    end

    def initialize(time_attr={})
      super time_attr
      cast_to_time :starting_at, :ending_at
    end

    def time_range
      return self.time_of_day unless user_specified_time?

      return self.starting_at.strftime('%l:%M%p') if self.ending_at.blank?
      "#{self.starting_at.strftime('%-l:%M%p')}-#{self.ending_at.strftime('%-l:%M%p')}" 
    end

    def user_specified_time?
      self.time_of_day == 'Specific Time'
    end

    def save
      ResidentialService::ServiceTimePersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ServiceTimePersistence.destroy self
    end
  end
end
