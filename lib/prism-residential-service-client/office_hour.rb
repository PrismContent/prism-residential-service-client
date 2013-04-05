module ResidentialService
  class OfficeHour < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'office_hour_persistence')

    self.attribute_names = {
      :purpose => String, :recurrence => String, :ordinals => String, :weeks_of_month => String, 
      :starting_on => Date, :ending_on => Date, :starting_at => Time, :ending_at => Time, 
      :account_id => Integer, :id => Integer, :location_id => Integer 
    }

    validates_presence_of :purpose, :recurrence, :account_id

    class << self
      def find(account_id, office_hour_id = nil)
        ResidentialService::OfficeHourPersistence.find_for_account account_id, office_hour_id
      end
    end

    def initialize(office_hour_attr={})
      super
      cast_to_date :starting_on, :ending_on
      cast_to_time :starting_at, :ending_at
    end

    def location
      @location ||= ResidentialService::Location.find(self.account_id, self.location_id)
    end

    def location=(location)
      @location = location
      self.location_id = @location.id
    end

    def save
      ResidentialService::OfficeHourPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::OfficeHourPersistence.destroy self
    end
  end
end
