module ResidentialService
  class MealPersistence
    require File.expand_path(File.dirname(__FILE__), 'meal')

    class << self
      def find_for_account_id(account_id, instance_id = nil)
        target_url = case
          when instance_id.is_a?(Date)
            find_dated_for_account_id(account_id, instance_id)
          when instance_id.blank?
            find_all_for_account_id(account_id)
          else
            find_single_for_account_id(account_id, instance_id)
        end
      end

      def find_dated_for_account_id(account_id, a_date)
        response = Typhoeus::Request.get dated_collection_url(account_id, a_date)
        return_collection response
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
        return_collection response
      end

      def save(meal)
        target_url = persistence_url(meal)

        case persistence_method(meal)
          when :post
            response = Typhoeus::Request.post target_url, :body => meal.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => meal.attributes.to_json
        end
        
        if response.timed_out?
          meal.send("service_errors=".to_sym, "Connection timeout. Please try again soon.")
          return false
        end

        case response.code
          when 200
            return true
          when 201
            [:id, :position, :meal_type_name, :starting_at, :ending_at].each do |remote_attr|
              meal.send("#{remote_attr}=".to_sym, instance_from(response).send(remote_attr))
            end
            meal.position= instance_from(response).position
            return true
          when 0 
            meal.send("service_errors=".to_sym, "Unable to connect to service. Please try again soon.")
            return false  
          else
            meal.send("service_errors=".to_sym, error_from(response))
            return false
        end
      end

      def destroy(meal)
        response = Typhoeus::Request.delete instance_url(meal)
        response.code == 200
      end

      def persistence_method( meal )
        meal.new_record? ? :post : :put
      end

      def persistence_url(meal)
        meal.new_record? ? dated_collection_url(meal.account_id, meal.served_on) : instance_url(meal)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::Meal)
          "#{collection_url(args.first.account_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def dated_collection_url(account_id, a_date)
        "#{collection_url(account_id)}/#{a_date.year}/#{a_date.month}/#{a_date.day}"
      end

      def collection_url(account_id)
        "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/meals"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      private
        def return_collection(response)
          if response.code == 200
            return collection_from(response)
          else
            return nil
          end
        end

        def collection_from(response)
          attrs = json_data(response)['meals']
          attrs.map{|attr| ResidentialService::Meal.new(attr) }
        end

        def instance_from(response)
          attr = json_data(response)['meal']
          ResidentialService::Meal.new attr
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
