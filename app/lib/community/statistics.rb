require "csv"

class Community::Statistics
  attr_reader :community

  def initialize(community)
    @community = community
  end

  def last_page_viewed_at
    PageView
      .joins(:membership)
      .where(memberships: {community_id: @community.id})
      .maximum(:created_at)
  end

  def moderator_emails
    @community.memberships.moderator.joins(:user).pluck(:email)
  end

  def total_of_users
    @community.users.count
  end

  def total_of_evaluation_feedbacks
    Message::HomeworkUploaded.in_community(@community).count
  end

  def total_of_evaluations
    Evaluation.in_community(@community).count
  end

  def total_of_expertises
    Subscription.in_community(@community).completed.count
  end

  def total_of_skills
    Skill.in_community(@community).count
  end

  def total_of_uploads
    Message::Upload.in_community(@community).count
  end

  def total_of_workspaces
    Workspace.where(community: @community).count
  end

  def total_of_events
    Event.where(community: @community).count
  end

  def total_of_hastags
    Message.in_community(@community).joins(:hash_tags).count
  end

  def total_of_votes
    Vote.in_community(@community).count
  end

  def total_of_pinned_messages
    Message::Text.pinned.in_community(@community).count
  end

  def total_of_messages
    Message::Text.in_community(@community).count
  end

  def total_of_page_views
    PageView.where(membership_id: @community.memberships.ids).count
  end

  def to_csv
    [
      @community.name,
      moderator_emails.join(", "),
      @community.created_at.to_date,
      last_page_viewed_at.try(:to_date),
      total_of_users,
      total_of_page_views,
      total_of_messages,
      total_of_pinned_messages,
      total_of_votes,
      total_of_hastags,
      total_of_events,
      total_of_workspaces,
      total_of_uploads,
      total_of_skills,
      total_of_expertises,
      total_of_evaluations,
      total_of_evaluation_feedbacks
    ]
  end

  def self.to_csv(communities)
    CSV.generate(headers: true) do |csv|
      csv << [
        Community.model_name.human,
        I18n.t("admin.communities.index.moderators"),
        Community.human_attribute_name(:created_at),
        I18n.t("admin.communities.statistics.last_activity"),
        User.model_name.human.pluralize,
        PageView.model_name.human(count: 2),
        Message.model_name.human.pluralize,
        "#{Message.model_name.human.pluralize} importants",
        Vote.model_name.human.pluralize,
        HashTag.model_name.human.pluralize,
        Event.model_name.human.pluralize,
        Workspace.model_name.human.pluralize,
        Message::Upload.model_name.human.pluralize,
        Skill.model_name.human.pluralize,
        I18n.t("admin.communities.statistics.expertises"),
        Evaluation.model_name.human.pluralize,
        I18n.t("admin.communities.statistics.evaluation_feedbacks")
      ]

      communities.find_each { |community| csv << community.statistics.to_csv }
    end
  end
end
