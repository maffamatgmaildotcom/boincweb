class BoincrpcJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    puts "starting..."
    ips = %w(192.168.5.87 192.168.5.91 192.168.5.92 192.168.5.93 192.168.5.94 192.168.5.95 192.168.5.96 192.168.5.97)
    #ips = %w(192.168.5.92)
      ips.each do |ip|
      puts "********************************************************************************************************"
      host = BoincRpc::Client.hostname(ip)
      #puts "for ip = #{ip} (#{host})..." 
      client = BoincRpc::Client.new(ip)
      # client.get_host_info
      client.get_results
    end 
  end
end
