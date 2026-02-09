class StatisticsController < ApplicationController
  before_action :check_authorization

  STATISTICS_ORDER_PARAM_PARSER = OrderParam::Parser.new.permit([
    :name,
    :last_page_viewed_at,
    :page_views,
    :messages,
    :pinned_messages,
    :event_participations,
    :received_votes,
    :uploads,
    :useful_uploads,
    :created_skills,
    :completed_skills,
    :evaluations,
    :evaluation_feedbacks,
    :expert_validations,
    :published_workspaces,
    :workspace_feedbacks
  ])

  def index
    users = current_community.users
    users = users.by_team(current_team) if current_team
    users = order_users_by(order_param, users)
    respond_to do |format|
      format.html { @users = users.page(params[:page]).per(100) }
      format.csv { send_data User::Statistics.to_csv(current_community, users) }
    end
  end

  def skills
    @users = current_community.users.order(:name).page(params[:page])
    @skills = current_community.skills.published.to_a
  end

  def check_authorization
    if !current_user || !current_user.permissions.read_community_statistics?(current_community)
      redirect_to(skills_path(current_community))
    end
  end

  private

  def order_users_by(order_params, users)
    return users if order_params.none?
    if order_param.attribute == :name
      users.order(name: order_params.order)
    else
      users
        .send("order_by_#{order_params.attribute}", current_community, order_params.order)
        .order(:name)
    end
  end

  def order_param
    STATISTICS_ORDER_PARAM_PARSER.parse(params[:order])
  end
end
