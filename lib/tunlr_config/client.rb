class TunlrConfig::Client < TunlrConfig

  def update(client_ip=nil)
    client_ip ||= self.class.remote_ip_from_ssh_env
    if client_ip.nil? || client_ip.empty?
      raise ArgumentError, "missing argument 'client_ip and IP not available from SSH_CLIENT environment variable."
    end

    self.logger.info("#{self.class}: updating client/home ip to: #{client_ip}, using server ip: #{self.server_ip}")

    self.copy_template(
       'named.conf.local', 
       {
         'SERVER_IP' => server_ip,
         'HOME_IP' => client_ip
       },
       '/etc/bind/named.conf.local'
    )

    self.reload_bind

    self.logger.info("#{self.class}: updating firewall rules")
    tunlr_exec(tunlr_script_path('tunlr-firewall.sh'), client_ip, server_ip)
  end

end
