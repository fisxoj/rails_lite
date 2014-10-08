require_relative '../phase6/controller_base'
require_relative 'flash'

module PhaseB1
  class ControllerBase < Phase5::ControllerBase
    def redirect_to(url)
      session.store_session(res)
      flash.store_session(res)
      super
    end

    def render_content(content, type)
      session.store_session(res)
      flash.store_session(res)
      super
    end

    # method exposing a `Flash` object
    def flash
      @flash ||= Flash.new(req)
    end
  end
end
