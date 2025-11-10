# frozen_string_literal: true

# Este es un ejemplo de cómo se vería un serializador para TikTok
# cuando decidas agregar soporte para esa red social

module TikTok
  module Serializers
    class BaseSerializer
      attr_reader :object

      def initialize(object)
        @object = object
      end

      # Método base para serializar - debe ser sobreescrito en subclases
      def as_json
        raise NotImplementedError, "#{self.class} must implement #as_json"
      end

      # Método de clase para serializar una colección
      def self.collection(objects, **options)
        objects.map { |obj| new(obj).as_json(**options) }
      end

      protected

      # Helper para formatear timestamps
      def format_timestamp(timestamp)
        timestamp&.iso8601
      end
    end
  end
end

# Ejemplo de uso:
# module TikTok
#   module Serializers
#     class ProfileSerializer < BaseSerializer
#       def as_json
#         {
#           id: object.id,
#           username: object.username,
#           display_name: object.display_name,
#           followers: object.followers_count,
#           following: object.following_count,
#           # ... más campos específicos de TikTok
#         }
#       end
#     end
#   end
# end

