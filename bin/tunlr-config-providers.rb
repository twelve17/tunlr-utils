#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/tunlr_config.rb'

options = { simulate: false, providers: [] }

op = OptionParser.new do |opts|
  opts.banner = "Usage: #$0 [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-pPROVIDERS", "--providers=PROVIDERS", "Comma delimited list of domains to configure.") do |p| 
    options[:providers] = (p.nil? || p.empty?) ? [] : p.split(/\s*,\s*/)
  end 

  opts.on("-sSERVER_IP", "--server-ip=SERVER_IP", "Optional: Your server's private/publcic IP address.  Defaults to first IPv4 interface's IP address.") do |s| 
    options[:server_ip] = s.strip
  end 

  opts.on("--simulate", "Do not copy really config files or run scripts.") do |sim| 
    options[:simulate] = true
  end 
end

op.parse!(ARGV)

if options[:providers].empty?
  raise ArgumentError, "You must provide at least one provider domain or a comma delimited list of provider domains to update."
end

providers = options.delete(:providers)
TunlrConfig::Providers.new(options).update(providers)


