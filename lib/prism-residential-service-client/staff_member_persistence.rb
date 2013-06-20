module ResidentialService
  class StaffMemberPersistence
    require File.expand_path(File.dirname(__FILE__), 'staff_member_persistence')

    class << self
      def find_for_account(account_id, instance_id = nil)
        instance_id.blank? ? find_all_for_account_id(account_id) : find_single_for_account_id(account_id, instance_id)
      end

      def find_single_for_account_id(account_id, instance_id)
        response = Typhoeus::Request.get(instance_url(account_id, instance_id))

        if response.code == 200
          return instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return collection_from(response)
        else
          return nil
        end
      end

      def proof(staff_member)
        return false if staff_member.new_record?
        @staff_member = staff_member

        new_attributes = staff_member.attributes.except(:state, :id)

        response = Typhoeus::Request.put proof_url(staff_member), :body => new_attributes.to_json
        handle_persistence_response response
      end

      def save(staff_member)
        @staff_member = staff_member
        target_url = persistence_url(staff_member)
        new_attributes = staff_member.attributes.except(:state, :id)

        response = Typhoeus::Request.send persistence_method(staff_member), target_url, :body => new_attributes.to_json
        handle_persistence_response response
      end

      def handle_persistence_response(response)
        case 
          when response.timed_out?
            @staff_member.send("service_errors=".to_sym, "Connection timeout. Please try again soon.")
            return false

          when response.code == 200
            instance = instance_from(response)
            @staff_member.state = instance.state
            return true

          when response.code == 201
            instance = instance_from(response)
            @staff_member.id = instance.id
            @staff_member.position = instance.position
            @staff_member.state = instance.state
            return true

          when response.code == 0 
            @staff_member.send("service_errors=".to_sym, "Unable to connect to service. Please try again soon.")
            return false  

          else
            @staff_member.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(staff_member)
        response = Typhoeus::Request.delete instance_url(staff_member)
        response.code == 200
      end

      def move(staff_member, direction)
        return false unless url = instance_move_url(staff_member, direction)

        if [:top, :bottom].include?(direction)
          response = Typhoeus::Request.put url
        else
          response = Typhoeus::Request.post url
        end

        if response.code==200
          staff_member.attributes = collection_from(response).
                                        detect{|position| position.id == staff_member.id }.
                                        attributes
        end

        response.code == 200
      end

      def proof_url(staff_member)
        return nil if staff_member.new_record?

        "#{instance_url(staff_member)}/proof"
      end

      def persistence_method( staff_member )
        staff_member.new_record? ? :post : :put
      end

      def persistence_url(staff_member)
        staff_member.new_record? ? collection_url(staff_member.account_id) : instance_url(staff_member)
      end

      def instance_move_url(staff_member, direction)
        case direction
          when :top
            "#{instance_url(staff_member)}/move_top"
          when :higher
            "#{instance_url(staff_member)}/move_up"
          when :lower
            "#{instance_url(staff_member)}/move_down"
          when :bottom
            "#{instance_url(staff_member)}/move_bottom"
          else
            nil
        end
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::StaffMember)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/staff_members"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        attrs = json_data(response)['staff_members']
        attrs.map{|attr| ResidentialService::StaffMember.new attr }
      end

      def instance_from(response)
        attr = json_data(response)['staff_member']
        ResidentialService::StaffMember.new attr 
      end

      def error_from(response)
        json_data(response)['error']
      end

      def json_data(response)
        JSON.parse(response.body) 
      end
    end
  end
end

