require 'logger'
require 'socket'

class TunlrConfig

  BASE_DIR=File.dirname(File.expand_path(File.join(__FILE__, '..')))

  attr_accessor :server_ip, :simulate
  attr_reader :logger

  protected

  def initialize(opts={})
    opts.each { |k,v| self.send("#{k}=", v) }
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    self.server_ip ||= TunlrConfig.my_first_public_ipv4
    self.logger.info("#{self.class}: base_dir: #{BASE_DIR}, simulate: #{self.simulate}")
  end
 
  def self.my_first_private_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
  end

  def self.my_first_public_ipv4
    Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}.ip_address
  end

  def self.remote_ip_from_ssh_env
    conn = ENV['SSH_CLIENT'].split(' ')
    return conn[0]
  end

  def tunlr_script_path(name)
    File.join(BASE_DIR, 'bin', name)
  end

  def service(name, action)
    if self.simulate
      self.logger.info("#{self.class}: SIMULATE: #{action.to_s} #{name}")
    else
      self.tunlr_exec('service', name, action.to_s) 
    end
  end

  def reload_bind
    self.service('bind9', :reload)
  end

  def tunlr_exec(*args)
     args_str = args.join(' ')
    if self.simulate
      self.logger.info("#{self.class}: SIMULATE: #{args_str}")
    else
      self.logger.info("#{self.class}: executing: #{args_str}")
      system(args_str)
      unless $?.exitstatus == 0
        raise "Last command exited with a non-zero exit code: #{$?.exitstatus}"
      end
    end
  end

  def copy_template(src_fn, tokens, dest_fn)
    output = self.process_template(src_fn, tokens)
    if self.simulate
      self.logger.info("write template #{dest_fn} with content:\n#{output}")
    else
      File.write(dest_fn, output)
    end
  end

  def process_template(fn, tokens)
    content = self.template_content(fn)
    tokens.each do |k,v|
      content = content.gsub("@#{k}@", v)
    end
    content 
  end

  def template_content(fn)
    File.read(File.join(BASE_DIR, 'templates', fn))
  end

end

require_relative 'tunlr_config/providers.rb'
require_relative 'tunlr_config/client.rb'
