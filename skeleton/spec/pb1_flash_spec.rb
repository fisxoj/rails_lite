require 'webrick'
require 'phaseb1/flash'
require 'phaseb1/controller_base'

describe PhaseB1::Flash do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_flash', { xyz: 'abc' }.to_json) }

  it "doesn't add a 'rails_lite_app' cookie" do
    flash = PhaseB1::Flash.new(req)
    flash['pasta'] = 'pizza'
    flash.store_flash(res)
    cookie = res.cookies.find { |c| c.name == '_rails_lite_app' }
    expect(cookie).to be nil
  end

  it "deserializes json cookie if one exists" do
    req.cookies << cook
    flash = PhaseB1::Flash.new(req)
    flash['xyz'].should == 'abc'
  end

  describe "#store_flash" do
    context "without cookies in request" do
      before(:each) do
        flash = PhaseB1::Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_rails_lite_flash' name to response" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        cookie.should_not be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        JSON.parse(cookie.value).should be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        cook = WEBrick::Cookie.new('_rails_lite_flash', { pho: "soup" }.to_json)
        req.cookies << cook
      end

      it "reads the pre-existing cookie data into hash" do
        flash = PhaseB1::Flash.new(req)
        flash['pho'].should == 'soup'
      end

      it "saves new and old data to the cookie" do
        flash = PhaseB1::Flash.new(req)
        flash['machine'] = 'mocha'
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_rails_lite_flash' }
        h = JSON.parse(cookie.value)
        h['machine'].should == 'mocha'
      end
    end

    context "with no flash in the request" do
      it "adds a cookie to the request" do
        flash = PhaseB1::Flash.new(req)
        flash.now['key'] = 'value'
        flash.store_flash(req)

        expect(flash['key']).to eq 'value'
      end
    end

    context "with cookies in the request" do
      it "adds to the existing cookies" do
        req.cookies << cook
        flash = PhaseB1::Flash.new(req)

        flash.now[:candy] = "yum"

        expect(flash[:candy]).to eq "yum"
        expect(flash[:xyz]).to eq "abc"
      end
    end
  end
end

describe PhaseB1::ControllerBase do
  before(:all) do
    class CatsController < PhaseB1::ControllerBase
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  describe "#flash" do
    it "returns a session instance" do
      expect(cats_controller.flash).to be_a(PhaseB1::Flash)
    end

    it "returns the same instance on successive invocations" do
      first_result = cats_controller.flash
      expect(cats_controller.flash).to be(first_result)
    end
  end

  shared_examples_for "storing flash data" do
    it "should store the session data" do
      cats_controller.flash.now['test_key'] = 'test_value'
      cats_controller.send(method, *args)
      expect(cats_controller.flash['test_key']).to eq('test_value')
    end
  end

  shared_examples_for "not accessing set flash data" do
    it "should not have access to next request's flash data" do
      cats_controller.flash['test_key'] = 'test_value'
      cats_controller.send(method, *args)
      expect(cats_controller.flash['test_key']).to be nil
    end
  end

  describe "#render_content" do
    let(:method) { :render_content }
    let(:args) { ['test', 'text/plain'] }
    include_examples "storing flash data"
    include_examples "not accessing set flash data"
  end

  describe "#redirect_to" do
    let(:method) { :redirect_to }
    let(:args) { ['http://appacademy.io'] }
    include_examples "storing flash data"
    include_examples "not accessing set flash data"
  end
end
