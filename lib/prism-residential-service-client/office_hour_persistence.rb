module ResidentialService
  class OfficeHourPersistence
    require File.expand_path(File.dirname(__FILE__), 'office_hour_persistence')

    class << self
      def find_for_account(account_id, instance_id = nil)
        instance_id.blank? ? find_all_for_account_id(account_id) : find_single_for_account_id(account_id, instance_id)
      end

      def find_single_for_account_id(account_id, instance_id)
        response = Typhoeus::Request.get(instance_url(account_id, instance_id))

        if response.code == 200
          return ResidentialService::OfficeHour.new instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return collection_from(response).map{|attr| ResidentialService::OfficeHour.new attr}
        else
          return nil
        end
      end

      def save(office_hour)
        target_url = persistence_url(office_hour)

        case persistence_method(office_hour)
          when :post
            response = Typhoeus::Request.post target_url, :body => office_hour.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => office_hour.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            office_hour.id= instance_from(response)['id']
            return true
          else
            office_hour.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(office_hour)
        response = Typhoeus::Request.delete instance_url(office_hour)
        response.code == 200
      end

      def persistence_method( office_hour )
        office_hour.new_record? ? :post : :put
      end

      def persistence_url(office_hour)
        office_hour.new_record? ? collection_url(office_hour.account_id) : instance_url(office_hour)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::OfficeHour)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/office_hours"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        json_data(response)['office_hours']
      end

      def instance_from(response)
        json_data(response)['office_hour']
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

