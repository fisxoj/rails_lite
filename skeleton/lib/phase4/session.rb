require 'json'
require 'webrick'

module Phase4
  class Session
    COOKIE_NAME = '_rails_lite_app'
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      session_cookie = req.cookies.find { |cookie| cookie.name == COOKIE_NAME}
      @cookie = !!session_cookie ? JSON.parse(session_cookie.value) : nil
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
      res.cookies << WEBrick::Cookie.new(COOKIE_NAME, @cookie.to_json)
    end
  end
end
