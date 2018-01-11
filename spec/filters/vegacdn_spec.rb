# encoding: utf-8
require 'spec_helper'
require "logstash/filters/vegacdn"

describe LogStash::Filters::Vegacdn do
  describe "Set to Hello World" do
    let(:config) do <<-CONFIG
      filter {
        vegacdn {
          hit_miss => "hitmiss"
          byte_size  => "bytes"
          time_hertz => "request_time_tmp"
          ip  => "client_ip"
          ip_fw  => "http_x_forwarded_for"
        }
      } 
    CONFIG
    end
  end
end
