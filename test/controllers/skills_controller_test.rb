require "test_helper"

class SkillsControllerTest < ActionController::TestCase
  def test_index
    login(alexis)
    get(:index, params: {permalink: base})
    assert_response(:success)
  end

  def test_index_when_no_membership
    login(admin)
    get(:index, params: {permalink: communities(:base)})
    assert_redirected_to(invitation_requests_path(base))
  end

  def test_new
    login(users(:admin))
    get(:new, params: {permalink: "hep"})
    assert_response(:success)
  end

  def test_create
    login(admin)
    assert_difference("Task.count", 2) do
      assert_difference("admin.subscriptions.count") do
        assert_difference("hep.skills.count") do
          post(:create, params: {permalink: "hep", skill: skill_params, tasks: tasks_params})
          assert_redirected_to(skill_path(hep, Skill.last))
        end
      end
    end
  end

  def test_create_with_errors
    login(users(:admin))
    communities(:hep)
    post(:create, params: {permalink: "hep", skill: {name: "", description: ""}})
    assert_response(:success)
  end

  def test_create_with_parent
    login(alexis)
    programming = skills(:programming)
    assert_difference("programming.children.count") do
      post(:create, params: {permalink: base, skill: {name: "Test", description: "Test", parent_id: programming.id}})
      assert_redirected_to(skill_path(base, Skill.last))
    end
  end

  def test_create_when_parent_cannot_have_children
    login(alexis)
    ror = skills(:ror)
    assert_no_difference("ror.children.count") do
      assert_difference("Skill.count") do
        post(:create, params: {permalink: base, skill: {name: "Test", description: "Test", parent_id: ror.id}})
        assert_redirected_to(skill_path(base, Skill.last))
      end
    end
  end

  def test_show
    login(alexis)
    get(:show, params: {permalink: "base-secrete", id: skills(:ror).id})
    assert_response(:success)
  end

  def test_show_when_no_subscription
    login(users(:antoine))
    get(:show, params: {permalink: "base-secrete", id: skills(:ror).id})
    assert_response(:success)
  end

  def test_edit
    login(users(:alexis))
    get(:edit, params: {permalink: "base-secrete", id: skills(:js).id})
    assert_response(:success)
  end

  def test_update
    login(alexis)
    task_ruby = tasks(:ror_ruby)
    task_psql = tasks(:ror_psql)
    tasks_params = [
      {id: task_ruby.id, title: "New title", position: 2},
      {id: task_psql.id, title: "Install Psql", position: 1}
    ]
    patch(:update, params: {permalink: "base-secrete", id: ror.id, skill: {name: "ROR", minimum_prerequisites: 1}, tasks: tasks_params})
    assert_redirected_to("/base-secrete/skills/#{ror.id}")
    assert_equal("ROR", ror.reload.name)
    assert_equal(1, ror.minimum_prerequisites)
    assert_equal("New title", task_ruby.reload.title)
    assert_equal(2, task_ruby.position)
  end

  def test_update_when_unpublished
    login(users(:alexis))
    (skill = skills(:js)).update!(published_at: nil)
    patch(:update, params: {permalink: "base-secrete", id: skill.id, skill: {published_at: "1"}})
    assert_redirected_to("/base-secrete/skills/#{skill.id}")
    assert(skill.reload.published_at)
  end

  def test_update_with_error
    skill = skills(:js)
    login(users(:alexis))
    patch(:update, params: {permalink: "base-secrete", id: skill.id, skill: {name: ""}})
    assert_response(:success)
  end

  def test_destroy_child
    login(alexis)
    assert_difference("Skill.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", id: skills(:js).id})
      assert_redirected_to(skill_path(base, skills(:js).parent))
    end
  end

  def test_subsscribe_to_parent_skill
    login(antoine)
    skills(:programming).unsubscribe(antoine)
    assert_difference("antoine.skills.count", 2) do
      post(:subscribe, params: {permalink: "base-secrete", id: ror.id, mastered: "true"})
      assert_redirected_to("/base-secrete/skills/#{ror.id}")
    end
  end

  def test_subscribe_when_user_is_already_subscribed
    login(alexis)
    assert_no_difference("alexis.skills.count") do
      post(:subscribe, params: {permalink: "base-secrete", id: ror.id, mastered: "true"})
      assert_redirected_to("/base-secrete/skills/#{ror.id}")
    end
  end

  def test_unsubscribe_from_child_skill
    login(antoine)
    assert_difference("antoine.skills.count", -2) do
      delete(:unsubscribe, params: {permalink: "base-secrete", id: skills(:js).id})
      assert_redirected_to(skill_path(base, skills(:js).parent))
    end
  end

  def test_pin
    login(users(:alexis))
    subscription = subscriptions(:ror_alexis)
    post(:pin, params: {permalink: "base-secrete", id: skills(:ror).id})
    assert_redirected_to("/")
    assert(subscription.reload.pinned_at)
  end

  def test_unpin
    login(users(:alexis))
    subscription = subscriptions(:ror_alexis)
    subscription.touch(:pinned_at)
    post(:pin, params: {permalink: "base-secrete", id: skills(:ror).id})
    assert_redirected_to("/")
    refute(subscription.reload.pinned_at)
  end

  def skill_params
    {name: "Équations", description: "Équations à 2 inconnues"}
  end

  def tasks_params
    [{title: "Task 1", position: 1}, {title: "Task 2", position: 2}]
  end

  def test_progression
    login(alexis)
    get(:progression, params: {permalink: base, id: skills(:programming)})
    assert_response(:success)
  end

  def test_progression_when_skill_has_no_children
    login(alexis)
    skill = skills(:ror)
    get(:progression, params: {permalink: base, id: skill})
    assert_redirected_to(progression_skill_path(skill.parent))
  end

  def test_messages
    login(alexis)
    before_request = Time.now
    get(:messages, params: {permalink: base, id: skills(:ror)})
    assert_response(:success)
    assert(subscriptions(:ror_alexis).last_read_at > before_request)
  end
end
