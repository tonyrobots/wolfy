class ErrorsController < ApplicationController
  layout :error_layout
  
  def show
    @code = status_code
    render status: @code
  end
 
protected
 
  def status_code
    params[:code] || 500
  end
  
  def error_layout
    status_code == 500 ? "plain" : "application"
  end
 
end
