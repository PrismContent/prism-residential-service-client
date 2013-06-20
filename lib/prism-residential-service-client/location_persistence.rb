module ResidentialService
  class LocationPersistence
    require File.expand_path(File.dirname(__FILE__), 'location_persistence')

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

      def proof(location)
        return false if location.new_record?
        @location = location

        new_attributes = location.attributes.except(:state, :id)
        response = Typhoeus::Request.put proof_url(location), :body => new_attributes.to_json
        handle_persistence_response response        
      end

      def save(location)
        @location = location
        target_url = persistence_url(location)
        new_attributes = location.attributes.except :state, :id, :created_at, :updated_at

        response = Typhoeus::Request.send persistence_method(location), target_url, :body => new_attributes.to_json
        handle_persistence_response response 
      end

      def handle_persistence_response(response)
        case 
          when response.timed_out?
            @location.send("service_errors=".to_sym, "Connection timeout. Please try again soon.")
            return false

          when response.code == 200
            @location.state = instance_from(response).state
            return true

          when response.code == 201
            instance = instance_from(response)
            @location.id = instance.id
            @location.state = instance.state
            return true

          when response.code == 0 
            @location.send("service_errors=".to_sym, "Unable to connect to service. Please try again soon.")
            return false

          else
            @location.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(location)
        response = Typhoeus::Request.delete instance_url(location)
        response.code == 200
      end

      def proof_url(location)
        return nil if location.new_record?

        "#{instance_url(location)}/proof"
      end

      def persistence_method( location )
        location.new_record? ? :post : :put
      end

      def persistence_url(location)
        location.new_record? ? collection_url(location.account_id) : instance_url(location)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::Location)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/locations"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        attrs = json_data(response)['locations']
        attrs.map{|attr| ResidentialService::Location.new attr }
      end

      def instance_from(response)
        attr = json_data(response)['location']
        ResidentialService::Location.new attr
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

