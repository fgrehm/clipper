require "uri"
require "cgi"

module Wheels
  module Orm
    class Uri

      def initialize(uri)
        raise ArgumentError.new("URI must be a String") unless uri.is_a?(String)
        raise ArgumentError.new("URI must not be blank") if uri.blank?

        @s = uri.dup

        if @s =~ /^jdbc:/
          uri = uri.sub(/^jdbc:/, "jdbc+")
        end

        uri = ::URI::parse(uri)

        @host = uri.path.to_s.size > 0 ? uri.host : "localhost"
        @name = uri.path.to_s.size > 0 ? uri.path : uri.host
        @user = uri.user
        @password = uri.password
        @options = uri.query ? CGI::parse(uri.query) : {}

        @options.each_pair do |key, value|
          @options[key] = value.first if key[-2..-1] != "[]" && value.kind_of?(Array) && value.size == 1
        end

        @driver = uri.scheme.split(/[\:\+]/).compact.inject(Wheels::Orm::Repositories) do |c, name|
          c.const_get(name.capitalize)
        end
      end

      def driver
        @driver
      end

      def name
        @name
      end

      def user
        @user
      end

      def password
        @password
      end

      def options
        @options
      end

      def to_s
        @s
      end
    end
  end
end