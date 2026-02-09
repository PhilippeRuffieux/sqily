class SkillsController < ApplicationController
  include RespondMessages

  before_action :must_be_membership
  before_action :authenticate_user
  before_action :must_be_moderator_or_free_skill_creation, only: %i[create edit update]
  before_action :find_skill, except: %i[index new create]

  def index
  end

  def new
    @skill = Skill.new(skill_params)
    if params[:from_skill_id]
      skill = Skill.find(params[:from_skill_id])
      @skill.name = skill.name
      @skill.description = skill.description
      @skill.auto_evaluation = skill.auto_evaluation
      @skill.group_name = skill.group_name
      @skill.tasks = skill.tasks.map { |t| Task.new(title: t.title, position: t.position, skill: @skill) }
    end
  end

  def create
    form = SkillForm.new
    skill_params.merge(community: current_community, creator: current_user, tasks: tasks_params)
    if form.create(skill_params.merge(community: current_community, creator: current_user, tasks: tasks_params))
      redirect_to(skill_path(current_community, form.skill))
    else
      @skill = form.skill
      render(:new)
    end
  end

  def show
    @evaluations = @skill.evaluations.listable_by(current_user).one_version_per_user.order(id: :desc)
    if (@subscription = @skill.subscriptions.find_by_user_id(current_user.id))
      @exam = @subscription.exams.ongoing.first
      @subscription.build_draft(evaluation: @evaluations.first) if !@exam && !@subscription.draft
    end
  end

  def edit
  end

  def update
    if SkillForm.update(@skill, skill_params.merge(tasks: tasks_params)).result
      redirect_to(skill_path(current_community, @skill))
    else
      render(:edit)
    end
  end

  def messages
    @subscription = @skill.subscriptions.find_by_user_id(current_user.id) and @subscription.touch(:last_read_at)
    @messages = filter_messages(@skill.messages.limit(25))
    @previous_page_url = messages_path(current_community, skill_id: @skill.id, before: @messages.last.created_at.iso8601(6), after: nil, pinned: params[:pinned]) if @messages.size == 25
    render(:new_subscription) if !@subscription && !@skill.children.any?
  end

  def destroy
    if current_user.permissions.destroy_skill?(@skill)
      Skill::DeleteJob.perform_now(@skill.id)
      redirect_to_parent_or_skills_index(@skill)
    else
      redirect_to(skill_path(current_community, @skill, alert: t("lib.unauthorized")))
    end
  end

  def pin
    if (@subscription = current_user.subscriptions.find_by_skill_id(@skill.id))
      @subscription.toggle_pinned_at
    end
    redirect_to(request.referer || "/")
  end

  def subscribe
    @skill.subscribe(current_user)
    redirect_to(skill_path(current_community, @skill))
  end

  def unsubscribe
    @skill.unsubscribe(current_user)
    redirect_to_parent_or_skills_index(@skill)
  end

  def progression
    if @skill.children.none?
      redirect_to(progression_skill_path(@skill.parent))
    else
      @skills = @skill.children.published
      @users = current_community.users.order(:name).page(params[:page])
      @users = @users.by_team(params[:team_id]) if params[:team_id].present?
    end
  end

  private

  def skill_params
    if params[:skill]
      hash = params.require(:skill).permit(:name, :description, :help, :minimum_prerequisites, :auto_evaluation, :parent_id, :mandatory)
      hash[:published_at] = Time.now if params[:skill][:published_at].to_i == 1
    end
    hash || {}
  end

  def tasks_params
    params.permit(tasks: [:id, :title, :position, :file])[:tasks]
  end

  def find_skill
    @skill = current_community.skills.find(params[:id])
  end

  def must_be_moderator_or_free_skill_creation
    current_community.free_skill_creation || must_be_moderator
  end

  def redirect_to_parent_or_skills_index(skill)
    if skill.parent
      redirect_to(skill_path(current_community, skill.parent))
    else
      redirect_to(skills_path(current_community))
    end
  end
end
