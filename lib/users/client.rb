require "faraday"

module Users
  class Client
    DEFAULT_HEADERS = {
      'Accept' => "application/vnd.dhusers+json; version=1"
    }
    SESSION_KEY_HEADER = 'X-Users-Session-Token'

    ME_PATH       = "/api/me"
    USERS_PATH    = "/api/users"
    LOGIN_PATH    = "/api/login"
    LOGOUT_PATH   = "/api/logout"

    AUTHENTICATIONS_PATH = "/api/authentications"

    attr_reader :api_key, :host

    def initialize(api_key, host)
      @api_key = api_key
      @host = host
    end

    def get_me(session_key)
      client.get do |req|
        req.url ME_PATH
        req.headers[SESSION_KEY_HEADER] = session_key
      end
    end

    def get_user(user_id)
      client.get "#{USERS_PATH}/#{user_id}"
    end

    def create_user(email, password, opts = {})
      client.post do |req|
        req.url USERS_PATH
        req.body = {
          :email                 => email,
          :password              => password
        }.merge(opts).to_json
      end
    end

    def login_user(email, password, opts = {})
      client.post do |req|
        req.url LOGIN_PATH
        req.body = {
          :email    => email,
          :password => password
        }.merge(opts).to_json
      end
    end

    def logout_user(session_key)
      client.delete do |req|
        req.url LOGOUT_PATH
        req.headers[SESSION_KEY_HEADER] = session_key
      end
    end

    def add_provider(session_key, opts = {})
      client.post do |req|
        req.url AUTHENTICATIONS_PATH
        req.headers[SESSION_KEY_HEADER] = session_key
        req.body = {
          :auth => opts
        }.to_json
      end
    end

    def remove_provider(session_key, auth_id)
      client.delete do |req|
        req.url "#{AUTHENTICATIONS_PATH}/#{auth_id}"
        req.headers[SESSION_KEY_HEADER] = session_key
      end
    end

    def activate_user(session_key, token)
      client.put do |req|
        req.url "#{ME_PATH}/activate?token=#{token}"
        req.headers[SESSION_KEY_HEADER] = session_key
      end
    end

    def resend_activation_email(session_key)
      client.post do |req|
        req.url "#{ME_PATH}/resend_activation"
        req.headers[SESSION_KEY_HEADER] = session_key
      end
    end

    def request_password_reset(email)
      client.post "#{USERS_PATH}/password_resets"
    end

    def update_password(token, password, password_confirmation)
      client.put do |req|
        req.url "#{USERS_PATH}/password_resets/#{token}"
        req.body = {
          :password => password,
          :password_confirmation => password_confirmation
        }.to_json
      end
    end

    private

      def client
        @client ||= begin
          Faraday.new(:url => host, :headers => DEFAULT_HEADERS) do |conn|
            conn.request :json
            conn.response :json, :content_type => /\bjson$/
            conn.adapter Faraday.default_adapter
            conn.basic_auth(api_key, nil)
          end
        end
      end
  end
end
