class UpdateComputersJob < ApplicationJob
  queue_as :default

  def perform
    Computer.find_each do |computer|
      # Initialize your RPC client (adjust as needed for your app)
      client = BoincRpcClient.new(computer.ip, computer.port || 31416, computer.password || "deadbeef", true)
      # get_results creates or updates the computers (hosts) in the db
      client.get_host_info()
    end
  end
end
