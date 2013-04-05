module ResidentialService
  class Location < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'location_persistence')

    self.attribute_names = {
      :name => String, :code => String, :account_id => Integer, :id => Integer
    }

    validates_presence_of :name, :account_id

    class << self
      def find(account_id, location_id = nil)
        ResidentialService::LocationPersistence.find_for_account account_id, location_id
      end
    end

    def save
      ResidentialService::LocationPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::LocationPersistence.destroy self
    end
  end
end
