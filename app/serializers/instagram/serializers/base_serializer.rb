# frozen_string_literal: true

module Instagram
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

      # Helper para incluir relaciones opcionales
      def include_if(condition, key, value)
        condition ? { key => value } : {}
      end
    end
  end
end

