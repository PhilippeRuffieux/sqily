class SubscriptionsController < ApplicationController
  before_action :authenticate_user
  before_action :find_subscription, only: [:complete, :uncomplete]

  def complete
    @subscription.complete(current_user) if current_user.permissions.evaluate_subscription?(@subscription)
    redirect_to(skill_path(current_community, @subscription.skill))
  end

  def uncomplete
    @subscription.uncomplete if moderator?
    redirect_to(skill_path(current_community, @subscription.skill))
  end

  private

  def find_subscription
    @subscription = Subscription.find(params[:id])
  end
end
