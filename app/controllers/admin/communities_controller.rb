class Admin::CommunitiesController < Admin::BaseController
  before_action :find_community, only: %i[show update destroy duplicate]

  STATISTICS_ORDER_PARAM_PARSER = OrderParam::Parser.new.permit([
    :name,
    :last_page_viewed_at,
    :created_at,
    :users,
    :page_views,
    :messages,
    :pinned_messages,
    :votes,
    :hashtags,
    :events,
    :workspaces,
    :uploads,
    :skills,
    :expertises,
    :evaluations,
    :evaluation_feedbacks
  ])

  def index
    @communities = Community.filter_by(params).order_by(params[:order_by]).page(params[:page]).order(:name)
  end

  def create
    @community = Community.new(community_attributes)
    if @community.save
      @community.add_moderator(current_user)
      redirect_to(admin_communities_path)
    else
      index
      render(:index)
    end
  end

  def show
  end

  def update
    if @community.update(community_attributes)
      redirect_to(admin_communities_path, notice: "Communauté mise à jour.")
    else
      render(:show)
    end
  end

  def destroy
    Community::DeleteJob.perform_now(@community.id)
    redirect_to(admin_communities_path)
  end

  def duplicate
    attrs = @community.attributes.slice("name", "description", "free_skill_creation", "permalink")
    attrs["permalink"] += "-" + rand(999999).to_s
    new_community = Community::DuplicationJob.perform_now(@community.id, current_user.id, attrs)
    redirect_to(admin_community_path(new_community))
  end

  def statistics
    communities = order_communities_by(order_param, Community.all)

    respond_to do |format|
      format.html { @communities = communities.page(params[:page]) }
      format.csv {
        Community::SendStatisticsJob.perform_later(current_user.email)
        redirect_back(fallback_location: admin_communities_path, notice: "Vous allez recevoir les statistiques à l'adresse #{current_user.email}.")
      }
    end
  end

  private

  def community_attributes
    params.require(:community).permit(:name, :description, :free_skill_creation, :permalink, :public)
  end

  def find_community
    @community = Community.find_by_permalink(params[:id])
  end

  private

  def order_communities_by(order_params, communities)
    return communities if order_params.none?
    if order_param.attribute == :name
      communities.order(name: order_params.order)
    else
      communities
        .send("order_by_#{order_params.attribute}", order_params.order)
        .order(:name)
    end
  end

  def order_param
    STATISTICS_ORDER_PARAM_PARSER.parse(params[:order])
  end
end
