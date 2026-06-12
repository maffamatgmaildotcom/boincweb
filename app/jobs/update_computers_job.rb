class UpdateComputersJob < ApplicationJob
  queue_as :default

  def perform
    # puts "**************** HEY, I'm running the UpdateComputersJob (perform) ***************"
    begin
      Computer.find_each do |computer|
        # Initialize your RPC client (adjust as needed for your app)
        client = BoincRpcClient.new(computer.ip, computer.port || 31416, computer.password || "deadbeef", false)
        # get_results creates or updates the computers (hosts) in the db
        client.get_host_info()
      end
    rescue StandardError => e
      Rails.logger.error "--- An ERROR occurred in UpdateComputersJob (perform): #{e.message} ---"
      Rails.logger.error e.backtrace.join("\n")
      # Re-raise if you want it marked as a failed_execution
      raise e
    end
    # puts "**************** HEY, I'm done with the UpdateComputersJob (perform) ***************"
  end
end
