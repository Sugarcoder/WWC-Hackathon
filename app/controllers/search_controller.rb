class SearchController < ApplicationController

  def search_user

    return render json: [] unless params[:term].present? 
    result = []
    
    result = Search.search_user(params[:term], params['user_type'])

    render json: result
  end
  
end