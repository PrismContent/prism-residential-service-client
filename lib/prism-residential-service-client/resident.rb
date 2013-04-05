module ResidentialService
  class Resident < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'resident_persistence')

    self.attribute_names = [ 
      :first_name, :last_name, :spouse_name, :spouse_id, :married_on, 
      :moved_in_on, :moved_out_on, :born_on, :deceased_on,
      :room, :email, :account_id, :id
    ]

    validates_presence_of :first_name, :last_name, :account_id

    class << self
      def find(account_id, resident_id = nil)
        ResidentialService::ResidentPersistence.find_for_account account_id, resident_id
      end

      def birthdays_for_month(account_id, month_id)
        ResidentialService::ResidentPersistence.find_birthdays_for account_id, Date::MONTHNAMES[month_id].downcase
      end
    end

    def initialize(resident_attr={})
      super resident_attr
      cast_to_date :moved_in_on, :moved_out_on, :born_on, :deceased_on, :married_on
    end

    def save
      ResidentialService::ResidentPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ResidentPersistence.destroy self
    end
  end
end
