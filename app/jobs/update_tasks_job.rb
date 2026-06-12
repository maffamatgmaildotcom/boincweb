class UpdateTasksJob < ApplicationJob
  queue_as :default

  def perform
    # puts "**************** HEY, I'm running the UpdateTasksJob (perform) ***************"
    begin
      Computer.find_each do |computer|
        # Initialize your RPC client (adjust as needed for your app)
        client = BoincRpcClient.new(computer.ip, computer.port || 31416, computer.password || "deadbeef", false)
        # get_results creates or updates the tasks in the db
        result_tasks = client.get_results(computer.ip)
      
        # Remove tasks for this computer that no longer exist
        names = result_tasks.map(&:name)
        Task.where(computer: computer.name.downcase).where.not(name: names).destroy_all
      end
    rescue StandardError => e
      Rails.logger.error "--- An ERROR occurred in UpdateTasksJob (perform): #{e.message} ---"
      Rails.logger.error e.backtrace.join("\n")
      # Re-raise if you want it marked as a failed_execution
      raise e
    end
    # puts "**************** HEY, I'm done with the UpdateTasksJob (perform) ***************"
  end
end