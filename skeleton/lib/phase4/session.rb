require 'json'
require 'webrick'
require 'active_support/core_ext/hash/indifferent_access'

module Phase4
  class Session
    COOKIE_NAME = '_rails_lite_app'
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @req = req

      @cookie = ensure_cookie(req)
    end

    def cookie_name
      # class inheritance problem solved?
      COOKIE_NAME
    end

    def ensure_cookie(req)
      session_cookie = @req.cookies.find { |cookie| cookie.name == cookie_name }

      if session_cookie && session_cookie.value && session_cookie.value != 'null'
        return JSON.parse(session_cookie.value).with_indifferent_access
      end
      {}.with_indifferent_access
    end

    def [](key)
      cookie[key]
    end

    def []=(key, val)
      cookie[key] = val
    end

    def cookie
      @cookie ||= Hash.new(nil)
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      unless cookie.empty?
        res.cookies << WEBrick::Cookie.new(COOKIE_NAME, @cookie.to_json)
      end
    end
  end
end
