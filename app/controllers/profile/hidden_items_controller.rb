class Profile::HiddenItemsController < ApplicationController
  layout "attestation"

  def create
    HiddenProfileItem.create!(hiden_profile_item_params.merge(membership: current_membership))
    redirect_to(profile_membership_path(current_community, current_membership))
  end

  def destroy
    HiddenProfileItem.where(membership: current_membership, id: params[:id]).first.try(:destroy)
    redirect_to(profile_membership_path(current_community, current_membership))
  end

  def hiden_profile_item_params
    params.require(:hidden_profile_item).permit(:workspace_id, :subscription_id)
  end
end
