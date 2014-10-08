require 'webrick'

require_relative '../lib/phase6/router'
require_relative '../lib/phaseb2/controller_base'

class CSRFController < PhaseB2::ControllerBase
  def new
    render :new
  end

  def create
    render :create
  end
end

router = Phase6::Router.new
router.draw do
  get Regexp.new("^/cats/new$"), CSRFController, :new
  post Regexp.new("^/cats/$"), CSRFController, :create
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end
trap('INT') { server.shutdown }
server.start