module ResidentialService
  class AnniversaryPersistence
    class << self
      def find_anniversaries_for(account_id, month_id)
        response = Typhoeus::Request.get month_collection_url(account_id, month_id)

        if response.code == 200
          return collection_from(response)
        else
          return nil
        end
      end

      private
        def month_collection_url(account_id, month_id)
          "http://#{ResidentialService::Config.host}/v1/accounts/#{account_id}/anniversaries/#{month_id}"
        end

        def enqueue(request)
          ResidentialService::Config.hydra.queue(request)
        end

        def collection_from(response)
          puts "Response:\n #{json_data(response).inspect}"
          attrs = json_data(response)['anniversaries']

          attrs.map{|attr| ResidentialService::Anniversary.new attr }
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
