module Prism
  module Serializers
    module JSON
      def as_json(options)
        root = options[:root] || true

        if root
          root = self.class.name
          { root => self.attributes }
        else
          self.attributes
        end
      end
    end
  end
end
