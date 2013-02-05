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
          return ResidentialService::Location.new instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return collection_from(response).map{|attr| ResidentialService::Location.new attr}
        else
          return nil
        end
      end

      def save(location)
        target_url = persistence_url(location)

        case persistence_method(location)
          when :post
            response = Typhoeus::Request.post target_url, :body => location.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => location.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            location.id= instance_from(response)['id']
            return true
          else
            location.send("service_errors=".to_sym, JSON.parse(response.body)['error'])
            return false
        end
      end

      def destroy(location)
        response = Typhoeus::Request.delete instance_url(location)
        response.code == 200
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
        JSON.parse(response.body)['locations'].flatten
      end

      def instance_from(response)
        JSON.parse(response.body)['location']
      end

      def error_from(response)
        JSON.parse(response.body)['error']
      end
    end
  end
end

