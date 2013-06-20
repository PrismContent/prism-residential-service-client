module ResidentialService
  class ServiceOffering < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'service_offering_persistence')

    self.attribute_names = {
      :name => String, :description => String, :service_type => String, :state => String,
      :account_id => Integer, :id => Integer
    }

    validates_presence_of :name, :service_type, :account_id

    class << self
      def service_types
        @service_types ||= %w[transportation office_hours]
      end

      def find(account_id, service_offering_id = nil)
        ResidentialService::ServiceOfferingPersistence.find_for_account account_id, service_offering_id
      end
    end

    def proofed?
      self.state == 'proofed'
    end

    def proof(attrs)
      self.attributes = attrs
      ResidentialService::ServiceOfferingPersistence.proof(self) if valid?
    end

    def save
      ResidentialService::ServiceOfferingPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ServiceOfferingPersistence.destroy self
    end
  end
end
