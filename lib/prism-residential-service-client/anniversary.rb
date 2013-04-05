module ResidentialService
  class Anniversary < Prism::RemoteRecord
    require File.expand_path(File.dirname(__FILE__), 'anniversary_persistence')

    self.attribute_names= { :name => String, :married_on => Date, :spouse_ids => Array }

    class << self
      def find_for_month(account_id, month_id)
        ResidentialService::AnniversaryPersistence.find_anniversaries_for account_id, Date::MONTHNAMES[month_id].downcase
      end
    end

    def initialize(resident_attr={})
      super
      cast_to_date :married_on
    end

    def married_on=(marriage_date)
      @married_on = marriage_date.respond_to?(:to_date) ? marriage_date.to_date : marriage_date
    end
  end
end
