class PTCOM < Thor
  PT_DOMAINS = %w{
    telecom.pt
    corppt.com
    ptportugal-dev.local
  }

  desc "bypass", "Bypass the Great Firewall of PT and use Wireless for normal internet web surfing"
  def bypass
    static_route
    change_dns
    flush_dns
  end

  desc "nobypass", "Disable the bypassing of the Great Firewall of PT"
  def nobypass
    unchange_dns
    flush_dns
  end

  desc "static_route", "Add static route to routing table to map 10.x.x.x to ethernet gateway"
  def static_route
    system "sudo route add 10.0.0.0/8 10.101.72.1"
  end

  desc "change_dns", "Change the DNS servers for PT domains"
  def change_dns
    the_file  = PT_DOMAINS.first
    the_links = PT_DOMAINS[1..-1]

    if File.exists?("/etc/resolver/#{the_file}")
      puts "The file already exists: /etc/resolver/#{the_file}"
      return
    end

    # Create one file
    # Note that this runs the commands in a sub-shell to make the cd and file
    # redirection work.
    system "sudo sh -c 'echo \"#{RESOLVER_CONTENTS}\" > /etc/resolver/#{the_file}'"

    return unless File.exists?("/etc/resolver/#{the_file}")

    # Create the others as symbolic links
    the_links.each do |link|
      system "sudo ln -s /etc/resolver/#{the_file} /etc/resolver/#{link}"
    end

    flush_dns
  end

  desc "unchange_dns", "Revert the changes to DNS servers for PT domains"
  def unchange_dns
    PT_DOMAINS.each do |domain|
      file = "/etc/resolver/#{domain}"
      system "sudo rm #{file}"
    end

    flush_dns
  end


  desc "flush_dns", "Flush DNS Cache"
  def flush_dns
    system "sudo dscacheutil -flushcache"
  end

RESOLVER_CONTENTS =<<-txt.strip
nameserver 10.101.1.11
port 53
timeout 1
txt

end
