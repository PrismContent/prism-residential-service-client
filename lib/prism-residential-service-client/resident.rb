module ResidentialService
  class Resident
    require File.expand_path(File.dirname(__FILE__), 'resident_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if Object.const_defined?('ActiveModel')

    @@attributes = [:first_name, :last_name, :spouse_name, :spouse_id, :married_on, 
                    :moved_in_on, :moved_out_on, :born_on, :deceased_on,
                    :room, :email, :account_id, :id]

    attr_accessor *@@attributes

    validates_presence_of :first_name, :last_name, :account_id

    class << self
      def find(account_id, resident_id = nil)
        ResidentialService::ResidentPersistence.find_for_account account_id, resident_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|staff_position| staff_position.destroy }
      end

      def birthdays_for_month(account_id, month_id)
        ResidentialService::ResidentPersistence.find_birthdays_for account_id, Date::MONTHNAMES[month_id].downcase
      end
    end

    def initialize(resident_attr={})
      resident_attr = HashWithIndifferentAccess.new(resident_attr ||{})
      self.attributes = resident_attr.slice *@@attributes
      cast_to_date :moved_in_on, :moved_out_on, :born_on, :deceased_on, :married_on
    end

    def new_record?
      self.id.blank?
    end

    def update_attributes(attr={})
      attr.keys.each do |attr_id|
        self.send("#{attr_id}=", attr[attr_id])
      end
      save
    end

    def save
      ResidentialService::ResidentPersistence.save(self) if valid?
    end

    def destroy
      ResidentialService::ResidentPersistence.destroy self
    end

    def to_param
      send(:id).to_s
    end

    def to_key
      send(:id) ? [send(:id)] : nil
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

      def cast_to_time(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_time.in_time_zone
          end
        end
      end

      def cast_to_date(*attr_ids)
        attr_ids.each do |attr_id|
          if self.attributes[attr_id].is_a?(String)
            send "#{attr_id}=", self.attributes[attr_id].to_date
          end
        end
      end
  end
end
