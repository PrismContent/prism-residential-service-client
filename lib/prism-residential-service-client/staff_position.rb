module ResidentialService
  class StaffPosition < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'staff_position_persistence')

    self.attribute_names = {
      :name => String, :name => String, :sortable => String, :position => String, 
      :account_id => Integer, :id => Integer
    }

    validates_presence_of :name, :account_id

    class << self
      def find(account_id, staff_position_id = nil)
        ResidentialService::StaffPositionPersistence.find_for_account account_id, staff_position_id
      end
    end

    def sortable?
      !!attributes[:sortable]
    end

    def save
      ResidentialService::StaffPositionPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::StaffPositionPersistence.destroy self
    end

    def move(direction)
      ResidentialService::StaffPositionPersistence.move self, direction
    end
  end
end
