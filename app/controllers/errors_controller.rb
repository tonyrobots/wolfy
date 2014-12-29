class ErrorsController < ApplicationController
 
  def show
    @code = status_code
    render layout: "plain" if @code = 500 
  end
 
protected
 
  def status_code
    params[:code] || 500
  end
 
end
