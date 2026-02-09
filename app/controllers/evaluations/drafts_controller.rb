class Evaluations::DraftsController < ApplicationController
  def create
    subscription = current_user.subscriptions.find_by_id(draft_params[:subscription_id])
    if subscription && subscription.skill.evaluations.find_by_id(draft_params[:evaluation_id])
      Evaluation::Draft.find_or_initialize_by(subscription_id: subscription.id).update(draft_params)
      head(:ok)
    else
      head(:unprocessable_entity)
    end
  end

  private

  def draft_params
    params.require(:evaluation_draft).permit(:subscription_id, :evaluation_id, :content)
  end
end
