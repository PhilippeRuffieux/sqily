require "csv"

class User::Statistics
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def last_page_viewed_at(community)
    @user.memberships.find_by_community_id(community.id).page_views.maximum(:created_at)
  end

  def total_of_page_views(community)
    @user.memberships.find_by_community_id(community.id).page_views.count
  end

  def total_of_messages(community)
    Message::Text.where(from_user_id: @user.id).in_community(community).count
  end

  def total_of_pinned_messages(community)
    Message.in_community(community).where(from_user_id: @user.id).pinned.count
  end

  def total_of_event_participations(community)
    @user.participations.in_community(community).count
  end

  def total_of_received_votes(community)
    Vote.to_user(@user).in_community(community).count
  end

  def total_of_uploads(community)
    Message::Upload.in_community(community).where(from_user: @user).count
  end

  def total_of_useful_uploads(community)
    Message::Upload.in_community(community).where(from_user: @user).with_votes.count
  end

  def total_of_created_skills(community)
    Skill.where(community: community, creator: @user).count
  end

  def total_of_completed_skills(community)
    @user.subscriptions.in_community(community).completed.where.not(validator_id: nil).count
  end

  def total_of_evaluations(community)
    skill_ids = community.skills.published.pluck(:id)
    Evaluation.where(user_id: @user.id, skill_id: skill_ids).one_version_per_user.count
  end

  def total_of_evaluation_feedbacks(community)
    Message::HomeworkUploaded.in_community(community).where(to_user: @user).where.not(text: nil).count
  end

  def total_of_expert_validations(community)
    Subscription.where(validator: @user).in_community(community).count
  end

  def total_of_published_workspaces(community)
    Workspace::Partnership.writer.joins(:workspace).where(user: @user, workspaces: {community: community}).merge(Workspace.published).count
  end

  def total_of_workspace_feedbacks(community)
    Message::Text.joins(:to_workspace).where(from_user: @user, workspaces: {community_id: community}).count
  end

  def to_csv(community)
    last_page_viewed_at = @user.statistics.last_page_viewed_at(community)
    last_page_viewed_at = last_page_viewed_at ? I18n.l(last_page_viewed_at.to_date, format: :short) : "-"

    [
      @user.name,
      @user.email,
      last_page_viewed_at,
      @user.statistics.total_of_page_views(community),
      @user.statistics.total_of_messages(community),
      @user.statistics.total_of_pinned_messages(community),
      @user.statistics.total_of_event_participations(community),
      @user.statistics.total_of_received_votes(community),
      @user.statistics.total_of_uploads(community),
      @user.statistics.total_of_useful_uploads(community),
      @user.statistics.total_of_created_skills(community),
      @user.statistics.total_of_completed_skills(community),
      @user.statistics.total_of_evaluations(community),
      @user.statistics.total_of_evaluation_feedbacks(community),
      @user.statistics.total_of_expert_validations(community),
      @user.statistics.total_of_published_workspaces(community),
      @user.statistics.total_of_workspace_feedbacks(community)
    ]
  end

  def self.to_csv(community, users)
    CSV.generate(headers: true) do |csv|
      csv << [
        User.model_name.human.pluralize,
        User.human_attribute_name(:email),
        I18n.t("statistics.index.last_activity"),
        PageView.model_name.human(count: 2),
        Message.model_name.human(count: 2),
        I18n.t("statistics.index.important_messages"),
        I18n.t("statistics.index.participating_events"),
        I18n.t("statistics.index.votes_received"),
        Message::Upload.model_name.human(count: 2),
        I18n.t("statistics.index.useful_files"),
        I18n.t("statistics.index.created_skills"),
        I18n.t("statistics.index.completed_skills"),
        Evaluation.model_name.human(count: 2),
        I18n.t("statistics.index.evaluation_feedbacks"),
        I18n.t("statistics.index.validated_experts"),
        I18n.t("statistics.index.published_workspaces"),
        I18n.t("statistics.index.workspace_feebacks")
      ]

      users.find_each { |user| csv << user.statistics.to_csv(community) }
    end
  end
end
