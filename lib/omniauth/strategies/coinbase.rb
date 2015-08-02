require 'omniauth-oauth2'
require 'coinbase'

module OmniAuth
  module Strategies
    class Coinbase < OmniAuth::Strategies::OAuth2
      option :name, 'coinbase'
      option :client_options, {
              :site => 'https://www.coinbase.com',
              :proxy => ENV['http_proxy'] ? URI(ENV['http_proxy']) : nil,
              :ssl => {
                :verify => true,
                :cert_store => ::Coinbase::Client.whitelisted_cert_store
              }
      }
      option :authorize_options, [:scope, :meta]


      uid { raw_info['id'] }

      info do
        {
          :id => raw_info['id'],
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def raw_info
        @raw_info ||= MultiJson.load(access_token.get('/api/v1/users').body)['users'][0]['user']
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

    end
  end
end
