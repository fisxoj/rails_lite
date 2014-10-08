require_relative "../phaseb1/controller_base"

module PhaseB2
  class ControllerBase < PhaseB1::ControllerBase
    TOKEN_PARAMETER_NAME = '_authenticity_token'
    class AuthenticityTokenMissing < StandardError; end

    def auth_token
      @auth_token ||= SecureRandom.urlsafe_base64(32)
    end

    def insert_auth_token
      <<-HTML.html_safe
      <input type="hidden" name="#{TOKEN_PARAMETER_NAME}" value="#{auth_token}">
      HTML
    end

    def initialize(req, res, route_params = {})
      super
      check_csrf

      session[TOKEN_PARAMETER_NAME] = auth_token
    end

    protected
    def check_csrf
      # p [@req.request_method, session[TOKEN_PARAMETER_NAME], params[TOKEN_PARAMETER_NAME]]
      if @req.request_method == "POST" &&
              session[TOKEN_PARAMETER_NAME] != params[TOKEN_PARAMETER_NAME]
        raise AuthenticityTokenMissing
      end
    end
  end
end