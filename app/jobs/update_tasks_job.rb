class UpdateTasksJob < ApplicationJob
  queue_as :default

  def perform
    Computer.find_each do |computer|
      # Initialize your RPC client (adjust as needed for your app)
      client = BoincRpcClient.new(computer.ip, computer.port || 31416, computer.password || "deadbeef", true)
      # get_results creates or updates the tasks in the db
      result_tasks = client.get_results(computer.ip)
    
      # Remove tasks for this computer that no longer exist
      names = result_tasks.map(&:name)
      Task.where(computer: computer.name.downcase).where.not(name: names).destroy_all
    end
  end
end