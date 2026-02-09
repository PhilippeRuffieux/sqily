class Admin::CommunityRequestsController < Admin::BaseController
  def index
    @community_requests = CommunityRequest.pending.page(params[:page])
  end

  def destroy
    CommunityRequest.find(params[:id]).destroy
    redirect_to(admin_community_requests_path)
  end

  def accept
    CommunityRequest.find(params[:id]).accept
    redirect_to(admin_community_requests_path)
  end
end
