module ResidentialService
  class Anniversary
    require File.expand_path(File.dirname(__FILE__), 'anniversary_persistence')

    include Prism::Serializers::JSON

    @@attributes = [ :name, :married_on, :spouse_ids ]

    attr_accessor *@@attributes

    class << self
      def find_for_month(account_id, month_id)
        ResidentialService::AnniversaryPersistence.find_anniversaries_for account_id, Date::MONTHNAMES[month_id].downcase
      end
    end

    def initialize(resident_attr={})
      anniversary_attr = HashWithIndifferentAccess.new(resident_attr ||{})
      self.attributes = anniversary_attr.slice *@@attributes
    end

    def married_on=(marriage_date)
      @married_on = marriage_date.respond_to?(:to_date) ? marriage_date.to_date : marriage_date
    end

    def attributes
      @@attributes.inject(HashWithIndifferentAccess.new) do |attrs, key|
        attrs.merge key => read_attribute_for_validation(key)
      end
    end

    def attributes=(attrs)
      attrs.each_pair{|k,v| send "#{k}=", v}
    end

    def read_attribute_for_validation(key)
      send key
    end
    
    def service_errors
      @service_errors ||= {}
    end

    private
      def service_errors=(errors)
        @service_errors = errors
      end      
  end
end
