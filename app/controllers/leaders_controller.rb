class LeadersController < UsersController
  def destroy
    Leader.find(params[:id]).destroy
    redirect_to root_path
  end
end