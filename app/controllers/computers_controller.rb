class ComputersController < ApplicationController
  def index
    @computers =  Computer.where(active: true).order(:name)
  end
end