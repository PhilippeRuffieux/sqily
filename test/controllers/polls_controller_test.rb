require "test_helper"

class PollsControllerTest < ActionController::TestCase
  def setup
    login(alexis)
  end

  def test_create_to_community
    assert_difference("PollChoice.count", 3) do
      assert_difference("Poll.count") do
        post(:create, params: {
          permalink: base,
          single_answer: true,
          poll: {title: "Question", community_id: base.id, finished_at: 1.day.from_now},
          choices: ["Choix 1", "Choix 2", "Choix 3", "", " "]
        })
        assert_redirected_to(skills_path(base))
      end
    end
    assert_equal(alexis, (poll = Poll.last).user)
    assert(poll.single_answer)
  end

  def test_create_to_skill
    assert_difference("PollChoice.count", 3) do
      assert_difference("Poll.count") do
        post(:create, params: {
          permalink: base,
          poll: {title: "Question", skill_id: ror.id, finished_at: 1.day.from_now},
          choices: ["Choix 1", "Choix 2", "Choix 3", "", " "]
        })
        assert_redirected_to(skill_path(base, ror))
      end
    end
    assert_equal(alexis, Poll.last.user)
  end

  def test_create_to_workspace
    workspace = workspaces(:ror_development)
    assert_difference("PollChoice.count", 3) do
      assert_difference("Poll.count") do
        post(:create, params: {
          permalink: base,
          poll: {title: "Question", workspace_id: workspace.id, finished_at: 1.day.from_now},
          choices: ["Choix 1", "Choix 2", "Choix 3", "", " "]
        })
        assert_redirected_to(workspace_path(base, workspace))
      end
    end
    assert_equal(alexis, Poll.last.user)
  end

  def test_create_with_errors
    post(:create, params: {permalink: base, poll: {title: "Question"}, choices: ["Choix 1", "Choix 2"]})
    assert_response(:success)
  end

  def test_create_when_user_does_not_belong_to_community
    skip
  end

  def test_create_when_user_does_not_belong_to_skill
    skip
  end

  def test_show
    get(:show, params: {permalink: base, id: polls(:alexis_poll_to_base)})
    assert_response(:success)
  end

  def test_show_when_user_is_not_allowed_to_edit
    login(antoine)
    get(:show, params: {permalink: base, id: polls(:alexis_poll_to_base)})
    assert_response(:not_found)
  end

  def test_destroy
    assert_difference("Message::PollCreated.count", -1) do
      assert_difference("Poll.count", -1) do
        delete(:destroy, params: {permalink: base, id: polls(:alexis_poll_to_base)})
        assert_redirected_to(skills_path(base))
      end
    end
  end
end
