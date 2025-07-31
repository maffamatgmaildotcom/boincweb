class MainController < ApplicationController

  def index
  end

  def projects
    
  end

  def tasks
    
    if params[:computer].present?
      computer = Computer.where("lower(name) = ?", params[:computer].downcase).first
    end
    # Initialize the BoincRpcClient with the computer's IP, port, and password
    # computer ||= Computer.first
    if computer.present?
      computer_name = computer.name.downcase
      # ip = computer.ip
      # port = computer.port || 31416
      # password = computer.password || "deadbeef"
      # client = BoincRpcClient.new(ip, port, password, true)
      # result_tasks = client.get_results(ip)
      # names = result_tasks.map(&:name)

      # Task.where(computer: computer_name).where.not(name: names).each do |task|
      #   task.destroy
      # end
    end

     # @invoices = Invoice.order("#{sort_column} #{sort_direction}").page(params[:page]).per(10)
    @tasks = computer_name.present? ? Task.where(computer: computer_name).all : Task.all
    @tasks = @tasks.where(status: "Running") if params[:filter].present? && params[:filter] == "active"
    @tasks
  end

  def transfers
  end

  def messages
  end

  def history
  end

  def notices
  end
end
