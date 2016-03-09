require 'aws-sdk'

module WafUtil


  def self.get_ipset_id_by_name(ipset_name)
    waf = Aws::WAF::Client.new

    # short arm this - not going to have more than 100 any time this millenium
    list_ip_sets_response = waf.list_ip_sets next_marker: nil,
                                             limit: 100

    found_ipset = list_ip_sets_response.ip_sets.select { |ip_set| ip_set.name == ipset_name }
    if found_ipset.empty?
      raise "ipset #{ipset_name} not found"
    else
      found_ipset.first.ip_set_id
    end
  end
end