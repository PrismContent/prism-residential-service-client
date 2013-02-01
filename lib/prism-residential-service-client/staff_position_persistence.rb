module ResidentialService
  class StaffPositionPersistence
    class << self
      def find_for_account(account_id, instance_id = nil)
        instance_id.blank? ? find_all_for_account_id(account_id) : find_single_for_account_id(account_id, instance_id)
      end

      def find_single_for_account_id(account_id, instance_id)
        response = Typhoeus::Request.get(instance_url(account_id, instance_id))

        if response.code == 200
          return ResidentialService::StaffPosition.new staff_position_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return staff_positions_from(response).map{|attr| ResidentialService::StaffPosition.new attr}
        else
          return nil
        end
      end

      def save(staff_position)
        target_url = persistence_url(staff_position)

        case persistence_method(staff_position)
          when :post
            response = Typhoeus::Request.post target_url, :body => staff_position.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => staff_position.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            staff_position_attr = staff_position_from(response)
            staff_position.id = staff_position_attr['id']
            staff_position.position = staff_position_attr['position']
            return true
          else
            staff_position.send("service_errors=".to_sym, JSON.parse(response.body)['error'])
            return false
        end
      end

      def destroy(staff_position)
        response = Typhoeus::Request.delete instance_url(staff_position)
        response.code == 200
      end

      def move(staff_position, direction)
        return false unless url = instance_move_url(staff_position, direction)

        if [:top, :bottom].include?(direction)
          response = Typhoeus::Request.put url
        else
          response = Typhoeus::Request.post url
        end

        if response.code==200
          staff_position.attributes = staff_positions_from(response).
                                        map{|attr| ResidentialService::StaffPosition.new attr }.
                                        detect{|position| position.id == staff_position.id }.
                                        attributes
        end

        response.code == 200
      end

      def persistence_method( staff_position )
        staff_position.new_record? ? :post : :put
      end

      def persistence_url(staff_position)
        staff_position.new_record? ? collection_url(staff_position.account_id) : instance_url(staff_position)
      end

      def instance_move_url(staff_position, direction)
        case direction
          when :top
            "#{instance_url(staff_position)}/move_top"
          when :higher
            "#{instance_url(staff_position)}/move_up"
          when :lower
            "#{instance_url(staff_position)}/move_down"
          when :bottom
            "#{instance_url(staff_position)}/move_bottom"
          else
            nil
        end
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::StaffPosition)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/staff_positions"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def staff_positions_from(response)
        JSON.parse(response.body)['staff_positions'].flatten
      end

      def staff_position_from(response)
        JSON.parse(response.body)['staff_position']
      end

      def error_from(response)
        JSON.parse(response.body)['error']
      end
    end
  end
end

