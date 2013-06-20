module ResidentialService
  class Resident < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'resident_persistence')

    self.attribute_names = { 
      :first_name => String, :last_name => String, :spouse_name => String, :spouse_id => Integer, 
      :married_on => Date, :moved_in_on => Date, :moved_out_on => Date, :born_on => Date, 
      :deceased_on => Date, :room => String, :email => String, :state => String,
      :account_id => Integer, :id => Integer
    }

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

    def proofed?
      self.state == 'proofed'
    end

    def proof(attrs)
      self.attributes = attrs
      ResidentialService::ResidentPersistence.proof(self) if valid?
    end

    def save
      ResidentialService::ResidentPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ResidentPersistence.destroy self
    end
  end
end
