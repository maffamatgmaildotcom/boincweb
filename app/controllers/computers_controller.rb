class ComputersController < ApplicationController
  def index
    Computer.where(name: [nil, '']).destroy_all
    @computers = Computer.where(active: true).order(:name)
    @computers
  end
end