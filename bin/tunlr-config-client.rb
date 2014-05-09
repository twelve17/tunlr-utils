#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/tunlr_config.rb'

options = { simulate: false }

op = OptionParser.new do |opts|
  opts.banner = "Usage: #$0 [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-iCLIENT_IP", "--home-ip=CLIENT_IP", "client IP address (e.g. from your home cable/dsl/fiber/etc service). If omitted, an attempt is made to get it from the SSH_CLIENT environment variable.") do |i| 
    options[:client_ip] = i.strip
  end 

  opts.on("-sSERVER_IP", "--server-ip=SERVER_IP", "Optional: Your server's private/publcic IP address.  Defaults to first IPv4 interface's IP address.") do |s| 
    options[:server_ip] = s.strip
  end 

  opts.on("--simulate", "Do not copy really config files or run scripts.") do |sim| 
    options[:simulate] = true
  end 
end

op.parse!(ARGV)

client_ip = options.delete(:client_ip)
TunlrConfig::Client.new(options).update(client_ip)
