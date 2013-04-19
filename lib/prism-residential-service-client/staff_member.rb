module ResidentialService
  class StaffMember < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'staff_member_persistence')

    self.attribute_names = {
      :first_name => String, :last_name => String, :hired_on => Date, 
      :terminated_on => Date, :staff_position_id => Integer, :position => Integer, 
      :account_id => Integer, :id => Integer, :staff_position_name => String
    }

    validates_presence_of :first_name, :last_name, :staff_position_id, :account_id

    class << self
      def find(account_id, staff_member_id = nil)
        ResidentialService::StaffMemberPersistence.find_for_account account_id, staff_member_id
      end
    end

    def initialize(staff_member_attr={})
      super
      cast_to_date :hired_on, :terminated_on
    end

    def save
      ResidentialService::StaffMemberPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::StaffMemberPersistence.destroy self
    end

    def move(direction)
      ResidentialService::StaffMemberPersistence.move self, direction
    end
  end
end
