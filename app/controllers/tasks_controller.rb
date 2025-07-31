class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    computer = Computer.where("lower(name) = ?", params[:id].downcase).first
    if computer.nil?
      flash[:alert] = "Computer not registered."
      redirect_to tasks_path
    else
      ip = computer.ip
      port = computer.port || 31416
      password = computer.password || nil
      # Initialize the BoincRpcClient with the computer's IP, port, and password
      client = BoincRpcClient.new(ip, port, password, true)
      result_tasks = client.get_results(ip)
      names = result_tasks.map(&:name)
      Task.where(computer: ip).where.not(name: names).each do |task|
        task.destroy
      end
      # @invoices = Invoice.order("#{sort_column} #{sort_direction}").page(params[:page]).per(10)
      @tasks = Task.where(computer: ip).all
    end
  end
end