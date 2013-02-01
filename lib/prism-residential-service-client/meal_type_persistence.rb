module ResidentialService
  class MealTypePersistence
    class << self
      def find_for_account(account_id, instance_id = nil)
        instance_id.blank? ? find_all_for_account_id(account_id) : find_single_for_account_id(account_id, instance_id)
      end

      def find_single_for_account_id(account_id, instance_id)
        response = Typhoeus::Request.get(instance_url(account_id, instance_id))

        if response.code == 200
          return ResidentialService::MealType.new meal_type_from(response)
        else
          return nil
        end
      end

      def find_all_for_account_id(account_id)
        response = Typhoeus::Request.get collection_url(account_id)

        if response.code == 200
          return meal_types_from(response).map{|attr| ResidentialService::MealType.new attr}
        else
          return nil
        end
      end

      def save(meal_type)
        target_url = persistence_url(meal_type)

        case persistence_method(meal_type)
          when :post
            response = Typhoeus::Request.post target_url, :body => meal_type.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => meal_type.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            meal_type.id= meal_type_from(response)['id']
            return true
          else
            meal_type.send("service_errors=".to_sym, JSON.parse(response.body)['error'])
            return false
        end
      end

      def destroy(meal_type)
        response = Typhoeus::Request.delete instance_url(meal_type)
        response.code == 200
      end

      def persistence_method( meal_type )
        meal_type.new_record? ? :post : :put
      end

      def persistence_url(meal_type)
        meal_type.new_record? ? collection_url(meal_type.account_id) : instance_url(meal_type)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::MealType)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/meal_types"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def meal_types_from(response)
        JSON.parse(response.body)['meal_types'].flatten
      end

      def meal_type_from(response)
        JSON.parse(response.body)['meal_type']
      end

      def error_from(response)
        JSON.parse(response.body)['error']
      end
    end
  end
end
