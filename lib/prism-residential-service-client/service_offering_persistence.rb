module ResidentialService
  class ServiceOfferingPersistence
    require File.expand_path(File.dirname(__FILE__), 'service_offering_persistence')

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

      def save(service_offering)
        target_url = persistence_url(service_offering)

        case persistence_method(service_offering)
          when :post
            response = Typhoeus::Request.post target_url, :body => service_offering.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => service_offering.attributes.to_json
        end
        
        if response.timed_out?
          service_offering.send("service_errors=".to_sym, "Connection timeout. Please try again soon.")
          return false
        end

        case response.code
          when 200
            return true
          when 201
            service_offering.id= instance_from(response).id
            return true
          when 0 
            service_offering.send("service_errors=".to_sym, "Unable to connect to service. Please try again soon.")
            return false
          else
            service_offering.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(service_offering)
        response = Typhoeus::Request.delete instance_url(service_offering)
        response.code == 200
      end

      def persistence_method( service_offering )
        service_offering.new_record? ? :post : :put
      end

      def persistence_url(service_offering)
        service_offering.new_record? ? collection_url(service_offering.account_id) : instance_url(service_offering)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::ServiceOffering)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/service_offerings"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        attrs = json_data(response)['service_offerings']
        attrs.map{|attr| ResidentialService::ServiceOffering.new attr }
      end

      def instance_from(response)
        attr = json_data(response)['service_offering']
        ResidentialService::ServiceOffering.new attr
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

