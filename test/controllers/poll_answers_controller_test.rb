require "test_helper"

class PollAnswersControllerTest < ActionController::TestCase
  def setup
    login(user)
  end

  def test_create_to_community_with_2_answers
    poll.update!(single_answer: false)
    assert_difference("poll.answers.count", 2) do
      post(:create, params: {permalink: poll.community, choice_ids: [choice1.id, choice2.id]})
    end
    assert_redirected_to(skills_path(poll.community))
  end

  def test_create_to_skill
    poll.update!(community: nil, skill: skill = skills(:js))
    assert_difference("poll.answers.count") do
      post(:create, params: {permalink: skill.community, choice_ids: [choice1.id]})
    end
    assert_redirected_to(skill_path(skill.community, id: skill.id))
    answer = PollAnswer.last
    assert_equal(user, answer.user)
    assert_equal(choice1, answer.choice)
  end

  def test_create_to_workspace
    (workspace = workspaces(:ror_development)).touch(:published_at)
    poll.update!(community: nil, workspace: workspace)
    assert_difference("poll.answers.count") do
      post(:create, params: {permalink: base, choice_ids: [choice1.id]})
    end
    assert_redirected_to(workspace_path(base, id: workspace.id))
    answer = PollAnswer.last
    assert_equal(user, answer.user)
    assert_equal(choice1, answer.choice)
  end

  def test_create_when_user_has_already_answered
    choice1.answers.create!(user: user)
    assert_no_difference("PollAnswer.count") do
      post(:create, params: {permalink: poll.community, choice_ids: [choice1.id]})
    end
    assert_redirected_to(skills_path(poll.community))
  end

  private

  def user
    @user ||= users(:antoine)
  end

  def poll
    @poll ||= polls(:alexis_poll_to_base)
  end

  def choice1
    @choice1 ||= poll_choices(:choice1)
  end

  def choice2
    @choice2 ||= poll_choices(:choice2)
  end
end
