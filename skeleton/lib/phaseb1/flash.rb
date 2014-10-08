require 'json'
require 'webrick'
require 'active_support/core_ext/hash/indifferent_access'

require_relative "../phase4/session"

module PhaseB1
  class Flash < Phase4::Session
    COOKIE_NAME = "_rails_lite_flash"

    def cookie_name
      # class inheritance problem solved?
      COOKIE_NAME
    end

    def store_session(res)
      store_flash(res)
    end

    def store_flash(res)
      # We don't store the other cookie, it dies with its request
      # but we do stick any now[] values back into it
      unless cookie.empty?
        @req.cookies << WEBrick::Cookie.new(COOKIE_NAME, @cookie.to_json)
      end

      # We store the non-now[] values in the response cookie
      res.cookies << WEBrick::Cookie.new(COOKIE_NAME, self.later.to_json)
    end

    def now
      Now.new(self)
    end

    def []=(key, val)
      self.later[key] = val
    end

    def later
      # Cookie to be stored
      @later ||= Hash.new(nil).with_indifferent_access
    end

    # For simulating the flash.now[:key] in rails
    class Now
      def initialize(flash)
        @flash = flash
      end

      def []=(key, val)
        # Sets cookie in the req
        @flash.send(:cookie).send(:[]=, key, val)
      end
    end
  end
end