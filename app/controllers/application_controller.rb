class ApplicationController < ActionController::Base
  before_action :load_sidebar_computers
  
  private
  def load_sidebar_computers
    @computers = Computer.where(active: true).order(:name)
  end
end
