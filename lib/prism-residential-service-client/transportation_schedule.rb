module ResidentialService
  class TransportationSchedule < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'transportation_schedule_persistence')

    self.attribute_names = {
      :destination => String, :recurrence => String, :ordinals => String, :weeks_of_month => String, 
      :starting_on => Date, :ending_on => Date, :starting_at => Time, :ending_at => Time, 
      :account_id => Integer, :id => Integer
    }

    validates_presence_of :destination, :recurrence, :account_id

    class << self
      def find(account_id, transportation_schedule_id = nil)
        ResidentialService::TransportationSchedulePersistence.find_for_account account_id, transportation_schedule_id
      end
    end

    def initialize(transportation_schedule_attr={})
      super
      cast_to_date :starting_on, :ending_on
      cast_to_time :starting_at, :ending_at
    end

    def save
      ResidentialService::TransportationSchedulePersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::TransportationSchedulePersistence.destroy self
    end
  end
end
