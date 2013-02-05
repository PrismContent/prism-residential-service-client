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
          return ResidentialService::Resident.new instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return collection_from(response).map{|attr| ResidentialService::Resident.new attr}
        else
          return nil
        end
      end

      def save(resident)
        target_url = persistence_url(resident)

        case persistence_method(resident)
          when :post
            response = Typhoeus::Request.post target_url, :body => resident.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => resident.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            resident.id= instance_from(response)['id']
            return true
          else
            resident.send("service_errors=".to_sym, JSON.parse(response.body)['error'])
            return false
        end
      end

      def destroy(resident)
        response = Typhoeus::Request.delete instance_url(resident)
        response.code == 200
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

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/residents"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        JSON.parse(response.body)['residents'].flatten
      end

      def instance_from(response)
        JSON.parse(response.body)['resident']
      end

      def error_from(response)
        JSON.parse(response.body)['error']
      end
    end
  end
end

