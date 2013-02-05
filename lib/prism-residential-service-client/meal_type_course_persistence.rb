module ResidentialService
  class MealTypeCoursePersistence
    require File.expand_path(File.dirname(__FILE__), 'meal_type_course')

    class << self
      def find_for_meal_type(meal_type_id, instance_id = nil)
        instance_id.blank? ? find_all_for_meal_type_id(meal_type_id) : find_single_for_meal_type_id(meal_type_id, instance_id)
      end

      def find_single_for_meal_type_id(meal_type_id, instance_id)
        response = Typhoeus::Request.get(instance_url(meal_type_id, instance_id))

        if response.code == 200
          return instance_from(response)
        else
          return nil
        end
      end

      def find_all_for_meal_type_id(meal_type_id)
        response = Typhoeus::Request.get collection_url(meal_type_id)

        if response.code == 200
          return collection_from(response)
        else
          return nil
        end
      end

      def save(meal_type_course)
        target_url = persistence_url(meal_type_course)

        case persistence_method(meal_type_course)
          when :post
            response = Typhoeus::Request.post target_url, :body => meal_type_course.attributes.to_json
          when :put
            response = Typhoeus::Request.put target_url,  :body => meal_type_course.attributes.to_json
        end

        case response.code
          when 200
            return true
          when 201
            [:id, :position, :meal_type_name].each do |remote_attr|
              meal_type_course.send("#{remote_attr}=".to_sym, instance_from(response).send(remote_attr))
            end
            meal_type_course.position= instance_from(response).position
            return true
          else
            meal_type_course.send("service_errors=".to_sym, JSON.parse(response.body)['error'])
            return false
        end
      end

      def move(meal_type_course, direction)
        raise(ArgumentError, 'Direction must be higher, lower, top, or bottom.') unless [:higher, :lower, :top, :bottom].include?(direction)
        target_url = "#{instance_url(meal_type_course)}/position/#{direction}"

        response = Typhoeus::Request.put target_url,  :body => meal_type_course.attributes.to_json

        if response.code == 200
          meal_type_course.attributes = collection_from(response).detect{|course| course.id == meal_type_course.id }.attributes
        end

        response.code == 200
      end

      def destroy(meal_type_course)
        response = Typhoeus::Request.delete instance_url(meal_type_course)
        response.code == 200
      end

      def persistence_method( meal_type_course )
        meal_type_course.new_record? ? :post : :put
      end

      def persistence_url(meal_type_course)
        meal_type_course.new_record? ? collection_url(meal_type_course.meal_type_id) : instance_url(meal_type_course)
      end

      def instance_url(*args)
        if args.first.is_a?(ResidentialService::MealTypeCourse)
          "#{collection_url(args.first.meal_type_id)}/#{args.first.id}"
        else
          "#{collection_url(args.first)}/#{args.last}"
        end
      end

      def collection_url(meal_type_id)
        "http://#{ResidentialService::Config.host}/v1/meal_types/#{meal_type_id}/meal_type_courses"
      end

      def enqueue(request)
        ResidentialService::Config.hydra.queue(request)
      end

      def collection_from(response)
        JSON.parse(response.body)['meal_type_courses'].flatten.map{|attr| ResidentialService::MealTypeCourse.new(attr) }
      end

      def instance_from(response)
        ResidentialService::MealTypeCourse.new(JSON.parse(response.body)['meal_type_course'])
      end

      def error_from(response)
        JSON.parse(response.body)['error']
      end
    end
  end
end
