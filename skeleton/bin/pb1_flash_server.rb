require 'webrick'
require_relative '../lib/phaseb1/controller_base'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class FlashController < PhaseB1::ControllerBase
  def go
    flash.now['message'] = 'A message now'
    flash['future_message'] = 'A message that only shows up later.'
    render :index
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  FlashController.new(req, res).go
end

trap('INT') { server.shutdown }
server.start