module ResidentialService
  class ResidentPersistence
    require File.expand_path(File.dirname(__FILE__), 'resident_persistence')

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

      def find_birthdays_for(account_id, month_id)
        response = Typhoeus::Request.get birthday_url(account_id, month_id)

        if response.code == 200
          return collection_from(response)
        else
          return nil
        end
      end

      def proof(resident)
        return false if resident.new_record?

        @resident = resident
        new_attributes = resident.attributes.except :id, :state, :created_at, :updated_at

        response = Typhoeus::Request.put proof_url(resident), :body => new_attributes.to_json
        handle_persistence_response(response) 
      end

      def save(resident)
        @resident = resident
        target_url = persistence_url(resident)
        new_attributes = resident.attributes.except :id, :state, :created_at, :updated_at

        response = Typhoeus::Request.send persistence_method(resident), target_url, :body => new_attributes.to_json
        handle_persistence_response(response) 
      end

      def handle_persistence_response(response)
        case 
          when response.timed_out?
            @resident.send("service_errors=".to_sym, "Connection timeout. Please try again soon.")
            return false

          when response.code == 200
            @resident.state = instance_from(response).state
            return true

          when response.code == 201
            instance = instance_from(response)
            @resident.id = instance.id
            @resident.state = instance.state
            return true

          when response.code == 0 
            @resident.send("service_errors=".to_sym, "Unable to connect to service. Please try again soon.")
            return false  

          else
            @resident.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(resident)
        response = Typhoeus::Request.delete instance_url(resident)
        response.code == 200
      end

      def proof_url( resident )
        "#{persistence_url(resident)}/proof"
      end

      def persistence_method( resident )
        resident.new_record? ? :post : :put
      end

      def persistence_url(resident)
        resident.new_record? ? collection_url(resident.account_id) : instance_url(resident)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::Resident)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def birthday_url(account_id, month_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/birthdays/#{month_id}"
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/residents"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        attrs = json_data(response)['residents']
        attrs.map{|attr| ResidentialService::Resident.new attr }
      end

      def instance_from(response)
        attr = json_data(response)['resident']
        ResidentialService::Resident.new attr
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

