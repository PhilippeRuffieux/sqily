class Profile::MembershipsController < ApplicationController
  layout "attestation"

  def show
    @profile = ProfilePage.new(Membership.find(params[:id]))
  end

  def public
    current_membership.update(public: true)
    redirect_to(profile_membership_path(current_community, current_membership))
  end

  def private
    current_membership.update(public: false)
    redirect_to(profile_membership_path(current_community, current_membership))
  end
end
