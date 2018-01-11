# encoding: utf-8
require "ipaddr"
require "logstash/filters/base"
require "logstash/namespace"

# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Vegacdn < LogStash::Filters::Base

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

  config :hit_miss, :validate => :string, :default => "MISS"

  config :byte_size, :validate => :string, :default => 0

  config :time_hertz, :validate => :string, :default => 0

  config :ip, :validate => :string, :default => "127.0.0.1"

  config :ip_fw, :validate => :string
  #
  config :customer_bandwidth, :validate => :number, :default => 0

  config :customer_ip, :validate => :string, :default => "127.0.0.1"

  config :customer_isp, :validate => :string, :default => 'default_isp'

  config :customer_mask24, :validate => :string, :default => '127.0.0.1'


  # Tags the event on failure to look up geo information. This can be used in later analysis.
  config :tag_on_failure, :validate => :array, :default => ["_geoip_lookup_failure"]

  GEO_ISP = { "61.14.236.0/22" => "TPCOM-1" , "103.89.84.0/22" => "TPCOM-2" , "103.205.96.0/22" => "TPCOM-3" , "203.119.8.0/22" => "VNPT-ZONE1-1" , "203.119.72.0/22" => "VNPT-ZONE1-2" , "203.119.60.0/22" => "VNPT-ZONE1-3" , "203.119.44.0/22" => "VNPT-ZONE1-4" , "203.119.64.0/22" => "VNPT-ZONE1-5" , "203.119.58.0/23" => "VNPT-ZONE1-6" , "202.47.142.0/24" => "VNPT-ZONE1-7" , "42.96.6.0/24" => "VNPT-ZONE1-8" , "42.96.8.0/24" => "VNPT-ZONE1-9" , "203.162.0.0/16" => "VNPT-ZONE1-10" , "203.210.128.0/17" => "VNPT-ZONE1-11" , "221.132.0.0/18" => "VNPT-ZONE1-12" , "203.160.0.0/23" => "VNPT-ZONE1-13" , "222.252.0.0/14" => "VNPT-ZONE1-14" , "123.16.0.0/12" => "VNPT-ZONE1-15" , "113.160.0.0/11" => "VNPT-ZONE1-16" , "14.160.0.0/11" => "VNPT-ZONE1-17" , "14.224.0.0/11" => "VNPT-ZONE1-18" , "202.151.160.0/21" => "VNPT-ZONE1-19" , "210.86.224.0/21" => "VNPT-ZONE1-20" , "119.17.192.0/19" => "VNPT-ZONE1-21" , "119.15.160.0/20" => "VNPT-ZONE1-22" , "101.96.64.0/18" => "VNPT-ZONE1-23" , "113.52.32.0/19" => "VNPT-ZONE1-24" , "49.246.128.0/18" => "VNPT-ZONE1-25" , "49.246.192.0/19" => "VNPT-ZONE1-26" , "202.134.16.0/22" => "VNPT-ZONE1-27" , "119.18.184.0/21" => "VNPT-ZONE1-28" , "118.107.64.0/18" => "VNPT-ZONE1-29" , "103.227.112.0/22" => "VNPT-ZONE1-30" , "43.239.188.0/22" => "VNPT-ZONE1-31" , "203.113.128.0/18" => "VIETTEL-ZONE1-1" , "220.231.64.0/18" => "VIETTEL-ZONE1-2" , "117.0.0.0/13" => "VIETTEL-ZONE1-3" , "27.64.0.0/13" => "VIETTEL-ZONE1-4" , "171.224.0.0/11" => "VIETTEL-ZONE1-5" , "116.96.0.0/12" => "VIETTEL-ZONE1-6" , "125.212.128.0/17" => "VIETTEL-ZONE1-7" , "125.214.0.0/18" => "VIETTEL-ZONE1-8" , "203.190.160.0/20" => "VIETTEL-ZONE1-9" , "103.238.68.0/22" => "VIETTEL-ZONE1-10" , "115.84.176.0/21" => "VIETTEL-ZONE1-11" , "210.211.96.0/19" => "VIETTEL-ZONE1-12" , "103.1.208.0/22" => "VIETTEL-ZONE1-13" , "45.117.160.0/22" => "VIETTEL-ZONE1-14" , "27.72.0.0/13" => "VIETTEL-ZONE2-1" , "115.72.0.0/13" => "VIETTEL-ZONE2-2" , "125.234.0.0/15" => "VIETTEL-ZONE2-3" , "171.233.0.0/16" => "VIETTEL-ZONE2-4" , "203.128.240.0/21" => "VIETTEL-ZONE2-5" , "203.119.36.0/22" => "VIETTEL-ZONE2-6" , "117.122.124.0/22" => "VIETTEL-ZONE2-7" , "203.119.68.0/22" => "VIETTEL-ZONE2-8" , "221.132.30.0/23" => "VIETTEL-ZONE2-8" , "221.132.32.0/21" => "VIETTEL-ZONE2-10" , "103.84.76.0/22" => "VIETTEL-ZONE2-11" , "221.133.0.0/19" => "VIETTEL-ZONE2-12" , "221.121.0.0/18" => "VIETTEL-ZONE2-13" , "116.118.0.0/17" => "VIETTEL-ZONE2-14" , "180.93.0.0/16" => "VIETTEL-ZONE2-15" , "103.200.60.0/22" => "VIETTEL-ZONE2-16" , "203.196.24.0/22" => "VIETTEL-ZONE2-17" , "112.78.0.0/20" => "VIETTEL-ZONE2-18" , "125.253.112.0/20" => "VIETTEL-ZONE2-19" , "103.249.100.0/22" => "VIETTEL-ZONE2-20" , "45.117.164.0/22" => "VIETTEL-ZONE2-21" , "61.28.224.0/19" => "VIETTEL-ZONE2-22" , "45.127.252.0/22" => "VIETTEL-ZONE2-23" , "103.196.236.0/22" => "VIETTEL-ZONE2-24" , "202.43.108.0/22" => "VIETTEL-ZONE2-25" , "103.20.144.0/22" => "VIETTEL-ZONE2-26" , "202.151.168.0/21" => "VIETTEL-ZONE2-27" , "210.86.232.0/21" => "VIETTEL-ZONE2-28" , "119.17.224.0/19" => "VIETTEL-ZONE2-29" , "116.102.0.0/16" => "VIETTEL-ZONE2-30" , "119.15.176.0/20" => "VIETTEL-ZONE2-31" , "101.53.0.0/18" => "VIETTEL-ZONE2-32" , "203.171.28.0/22" => "VIETTEL-ZONE2-33" , "202.60.104.0/21" => "VIETTEL-ZONE2-34" , "103.238.72.0/22" => "VIETTEL-ZONE2-35" , "14.0.16.0/20" => "VIETTEL-ZONE2-36" , "103.229.40.0/22" => "VIETTEL-ZONE2-37" , "171.232.0.0/16" => "VIETTEL-ZONE2-38" , "210.245.0.0/17" => "FPT-ZONE1-1" , "113.22.0.0/16" => "FPT-ZONE1-2" , "113.23.0.0/17" => "FPT-ZONE1-3" , "183.80.0.0/16" => "FPT-ZONE1-4" , "1.52.0.0/14" => "FPT-ZONE1-5" , "42.112.0.0/13" => "FPT-ZONE1-6" , "42.118.251.0/24" => "FPT-ZONE1-7" , "42.114.0.0/15" => "FPT-ZONE1-8" , "42.113.128.0/17" => "FPT-ZONE1-9" , "103.35.64.0/22" => "FPT-ZONE1-10" , "43.239.148.0/22" => "FPT-ZONE1-11" , "118.70.0.0/15" => "FPT-ZONE1-12" , "180.148.128.0/20" => "FPT-ZONE1-13" , "111.65.240.0/20" => "FPT-ZONE1-14" , "183.81.0.0/17" => "FPT-ZONE2-1" , "58.186.0.0/15" => "FPT-ZONE2-2" , "118.68.0.0/15" => "FPT-ZONE2-3" , "42.119.24.0/22" => "FPT-ZONE2-4" , "42.119.128.0/17" => "FPT-ZONE2-5" , "42.116.250.0/22" => "FPT-ZONE2-6" , "42.112.128.0/17" => "FPT-ZONE2-7" , "183.91.0.0/19" => "CMC-ZONE1-1" , "101.99.0.0/18" => "CMC-ZONE1-2" , "203.205.0.0/18" => "CMC-ZONE1-3" , "103.9.196.0/22" => "CMC-ZONE1-4" , "113.20.96.0/19" => "CMC-ZONE1-5" , "45.122.232.0/22" => "CMC-ZONE1-6" , "115.146.120.0/21" => "CMC-ZONE1-7" , "124.158.0.0/21" => "CMC-ZONE1-8" , "103.21.148.0/22" => "CMC-ZONE1-9" , "115.165.160.0/21" => "CMC-ZONE1-10" , "124.158.8.0/21" => "CMC-ZONE1-11" , "103.63.120.0/22" => "CMC-ZONE1-12" , "45.122.236.0/22" => "CMC-ZONE1-13" , "103.63.116.0/22" => "CMC-ZONE1-14" , "45.122.240.0/22" => "CMC-ZONE1-15" , "103.63.104.0/22" => "CMC-ZONE1-16" , "45.122.248.0/22" => "CMC-ZONE1-17" , "103.63.108.0/22" => "CMC-ZONE1-18" , "45.122.252.0/22" => "CMC-ZONE1-19" , "103.63.112.0/22" => "CMC-ZONE1-20" , "45.122.244.0/22" => "CMC-ZONE1-21" , "112.197.0.0/16" => "CMC-ZONE1-22" , "27.2.0.0/15" => "CMC-ZONE1-23" , "103.27.64.0/22" => "CMC-ZONE1-24" , "103.233.48.0/22" => "CMC-ZONE1-25" , "45.124.88.0/22" => "CMC-ZONE1-26", "127.0.0.1/32" => "default_isp" }


  public
  def register
  end

  public
  def filter(event)

    client_ip = IPAddr.new(event.get(@ip)) rescue IPAddr.new('127.0.0.1')
    http_xfw = IPAddr.new(event.get(@ip_fw)) rescue nil
    ip_addr = http_xfw || client_ip
    @customer_ip = ip_addr.to_s
    request_time = event.get(@time_hertz).to_f / 1000000
    @customer_mask24 = ip_addr.mask(24).to_s rescue '127.0.0.1'
    result = GEO_ISP.find{|k , v| IPAddr.new(k) === ip_addr} || ['127.0.0.1' , 'default_isp']
    @customer_isp = result[1]
    if request_time < 0.05
      @customer_bandwidth = 1000000000
    else
      @customer_bandwidth = ( event.get(@byte_size).to_f / request_time).to_i
    end
    event.set('hitmiss', event.get(@hit_miss).upcase)
    event.set('customer_ip', @customer_ip)
    event.set('customer_isp', @customer_isp)
    event.set('customer_mask24', @customer_mask24)
    event.set('customer_bandwidth', @customer_bandwidth)
    event.set('request_time', request_time)

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end
