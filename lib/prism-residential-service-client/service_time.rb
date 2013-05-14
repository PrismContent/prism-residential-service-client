module ResidentialService
  class ServiceTime < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'service_time_persistence')

    self.attribute_names = {
      :id => Integer, :service_offering_id => Integer, 
      :wday => Integer, :starting_at => Time, :ending_at => Time
    }

    validates_presence_of :wday, :starting_at

    class << self
      def find(service_offering_id, service_time_id = nil)
        ResidentialService::ServiceTimePersistence.find_for_service_offering service_offering_id, service_time_id
      end
    end

    def save
      ResidentialService::ServiceTimePersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ServiceTimePersistence.destroy self
    end
  end
end
