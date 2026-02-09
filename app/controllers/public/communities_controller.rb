class Public::CommunitiesController < ApplicationController
  layout "public"

  def index
    @communities = Community
      .includes(:memberships, :skills)
      .where(public: true)
      .order(:name)
      .page(params[:page])
  end
end
