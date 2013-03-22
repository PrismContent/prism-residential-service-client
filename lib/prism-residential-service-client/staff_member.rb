module ResidentialService
  class StaffMember
    require File.expand_path(File.dirname(__FILE__), 'staff_member_persistence')

    include Prism::Serializers::JSON

    include Prism::Validation::InstanceMethods
    extend  Prism::Validation::ClassMethods

    extend ActiveModel::Naming if Object.const_defined?('ActiveModel')

    @@attributes = [:first_name, :last_name, :hired_on, :terminated_on, 
                    :staff_position_id, :position, :account_id, :id]

    attr_accessor *@@attributes

    validates_presence_of :first_name, :last_name, :staff_position_id, :account_id

    class << self
      def find(account_id, staff_member_id = nil)
        ResidentialService::StaffMemberPersistence.find_for_account account_id, staff_member_id
      end

      def create(attributes={})
        instance = new(attributes)
        instance.save if instance.valid?
        instance
      end

      def delete_all(account_id)
        find(account_id).each{|member| member.destroy}
      end
    end

    def initialize(staff_member_attr={})
      staff_member_attr = HashWithIndifferentAccess.new(staff_member_attr ||{})
      self.attributes = staff_member_attr.slice *@@attributes

      cast_to_date :hired_on, :terminated_on
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
      ResidentialService::StaffMemberPersistence.save self
    end

    def destroy
      ResidentialService::StaffMemberPersistence.destroy self
    end

    def move(direction)
      ResidentialService::StaffMemberPersistence.move self, direction
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
            send "#{attr_id}=", self.attributes[attr_id].to_time
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
