class TunlrConfig::Providers < TunlrConfig

  BIND_ZONE_OVERRIDES_CONFIG='/etc/bind/zones.override'
  SNIPROXY_CONFIG='/etc/sniproxy.conf'

  def update(providers)
    raise "Missing providers" if providers.nil? || providers.empty?
    self.logger.info("#{self.class}: updating providers using server ip: #{self.server_ip}")

    self.generate_bind_zone_overrides(providers)
    self.generate_sniproxy_config(providers)

    self.reload_bind
    self.service('sniproxy', :restart)
  end

  protected

  def generate_bind_zone_overrides(providers)
    @template ||= self.template_content('zones.override.stanza')
    content = providers.map { |domain| self.bind_zone_stanza(domain) }.
      join("\n\n")
    if self.simulate
      self.logger.info("write template #{BIND_ZONE_OVERRIDES_CONFIG} with content:\n#{content}")
    else
      File.write(BIND_ZONE_OVERRIDES_CONFIG, content)
    end
    @template = nil
  end

  def bind_zone_stanza(domain)
    return @template.gsub('@DOMAIN@', domain)
  end

  def generate_sniproxy_config(providers)
    table_stanza = self.sniproxy_table_stanza(providers)
    self.copy_template(
       'sniproxy.conf', 
       {
         'SERVER_IP' => self.server_ip,
         'TABLE' => table_stanza
       },
       SNIPROXY_CONFIG
    )
  end

  def sniproxy_table_stanza(domains)
    stanza = []
    domains.each do |domain|
      stanza.push("    #{domain.gsub('.','\.')} *")
    end
    stanza.join("\n")
  end

end


