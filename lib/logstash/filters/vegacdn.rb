# encoding: utf-8
require "ipaddr"
require "logstash/filters/base"
require "logstash/namespace"

# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Example < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "vegacdn"

  # Replace the message with this value.

  config :hitmiss, :validate => :string, :default => "MISS"

  config :bytes, :validate => :number, :default => 0

  config :request_time_tmp, :validate => :number, :default => 0

  config :customer_bandwidth, :validate => :number, :default => 0

  config :client_ip, :validate => :string, :default => "127.0.0.1"

  config :http_x_forwarded_for, :validate => :string

  config :customer_ip, :validate => :string, :default => "127.0.0.1"

  config :customer_isp, :validate => :string, :default => 'default_isp'

  config :customer_mask24, :validate => :string, :default => '127.0.0.1'


  # Tags the event on failure to look up geo information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_geoip_lookup_failure"]

  public
  def register
  end

  public
  def filter(event)
    client_ip = event.get(@client_ip)
    http_xfw = event.get(@http_x_forwarded_for)
    client_ip_ = IPAddr.new(client_ip) rescue IPAddr.new('127.0.0.1')
    http_xfw_ = IPAddr.new(http_xfw) rescue nil
    ip_addr = http_xfw_ || client_ip_

    request_time = event.get(@request_time_tmp).to_f / 1000000

    ip_mask24 = ip_addr.mask(24).to_s rescue '127.0.0.1'

    result = GEO_ISP.find{|k , v| IPAddr.new(k) === ip_addr} || ['127.0.0.1' , 'default_isp']

    if request_time < 0.05
      @customer_bandwidth = 1000000
    else
      @customer_bandwidth = ( event.get(@bytes).to_f / request_time).to_i
    end

    event.set('hitmiss', @hitmiss.upcase)
    event.set('customer_ip', ip_addr.to_s)
    event.set('customer_isp', result[1])
    event.set('customer_mask24', ip_mask24)
    event.set('customer_bandwidth', @customer_bandwidth)
    event.set('request_time', request_time)

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Example
