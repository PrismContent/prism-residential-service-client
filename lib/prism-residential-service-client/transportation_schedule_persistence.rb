module ResidentialService
  class TransportationSchedulePersistence
    require File.expand_path(File.dirname(__FILE__), 'transportation_schedule_persistence')

    class << self
      def find_for_account(account_id, instance_id = nil)
        instance_id.blank? ? find_all_for_account_id(account_id) : find_single_for_account_id(account_id, instance_id)
      end

      def find_single_for_account_id(account_id, instance_id)
        response = Typhoeus::Request.get(instance_url(account_id, instance_id))

        if response.code == 200
          return ResidentialService::TransportationSchedule.new instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return collection_from(response).map{|attr| ResidentialService::TransportationSchedule.new attr}
        else
          return nil
        end
      end

      def save(transportation_schedule)
        target_url = persistence_url(transportation_schedule)

        case persistence_method(transportation_schedule)
          when :post
            response = Typhoeus::Request.post target_url, :body => transportation_schedule.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => transportation_schedule.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            transportation_schedule.id= instance_from(response)['id']
            return true
          else
            transportation_schedule.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(transportation_schedule)
        response = Typhoeus::Request.delete instance_url(transportation_schedule)
        response.code == 200
      end

      def persistence_method( transportation_schedule )
        transportation_schedule.new_record? ? :post : :put
      end

      def persistence_url(transportation_schedule)
        transportation_schedule.new_record? ? collection_url(transportation_schedule.account_id) : instance_url(transportation_schedule)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::TransportationSchedule)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/transportation_schedules"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        json_data(response)['transportation_schedules']
      end

      def instance_from(response)
        json_data(response)['transportation_schedule']
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

