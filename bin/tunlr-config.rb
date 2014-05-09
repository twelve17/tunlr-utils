#!/usr/bin/env ruby

require_relative '../lib/tunlr_config.rb'

options = { simulate: false }

raise ArgumentError, "SSH_ORIGINAL_COMMAND is not set." unless ENV['SSH_ORIGINAL_COMMAND']

parts = ENV['SSH_ORIGINAL_COMMAND'].split(/\s+/)

parts.shift # sudo
script_name = parts.shift # /opt/tunlr-utils/bin/tunlr-config.rb
cmd = parts.shift

# This shouldn't happen, but I'm paranoid
raise ArgumentError, "Invalid script: #{script_name}" \
  unless script_name.eql?('/opt/tunlr-utils/bin/tunlr-config.rb')

case cmd 
when 'client'
  # IP will be extracted from SSH_CLIENT
  TunlrConfig::Client.new(options).update
when 'providers'
  if (providers = parts.shift) && providers =~ /\A[a-zA-Z0-9\.,\-]+\Z/
    TunlrConfig::Providers.new(options).update(providers.split(/\s*,\s*/))
  else
    raise ArgumentError, "Missing providers argument does not look like what I expect: #{providers}"
  end
else
    raise ArgumentError, "unknown command: #{cmd}"
end

