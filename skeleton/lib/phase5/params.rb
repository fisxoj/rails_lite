require 'uri'
require 'active_support/core_ext/hash/indifferent_access'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})
      @req = req
      @params = ActiveSupport::HashWithIndifferentAccess.new(route_params)
      parse_www_encoded_form(req.query_string) if req.query_string
      parse_www_encoded_form(req.body) if req.body
    end

    def [](key)
      @params.with_indifferent_access[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      URI.unescape(www_encoded_form).split('&').each do |let|

        slot, value = let.split('=')

        keys = parse_key(slot)

        assign_nested(@params, keys, value)
      end
    end

    def assign_nested(ref, keys, value)
      if keys.count == 1
        ref[keys.first] = value
      else
        ref[keys.first] ||= ActiveSupport::HashWithIndifferentAccess.new(nil)
        assign_nested(ref[keys.first], keys[1..-1], value)
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.scan(/\w+/)
    end
  end
end
