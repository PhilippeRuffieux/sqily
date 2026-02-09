require "test_helper"

class EvaluationsControllerTest < ActionController::TestCase
  def setup
    Evaluation.any_instance.stubs(:save_file)
  end

  def test_create
    login(alexis)
    evaluation_params = {description: "plop", title: "test"}
    assert_difference("Evaluation.count") do
      post(:create, params: {permalink: "base-secrete", skill_id: ror.id, evaluation: evaluation_params})
      assert_redirected_to(skill_path(base, ror))
    end
    assert_equal("test", Evaluation.last.title)
    assert_equal("plop", Evaluation.last.description)
  end

  def test_update
    login(alexis)
    evaluation = evaluations(:js2)
    evaluation_params = {description: "plop", title: "test"}
    patch(:update, params: {permalink: "base-secrete", id: evaluation, evaluation: evaluation_params})
    evaluation.reload
    assert_equal("test", evaluation.title)
    assert_equal("plop", evaluation.description)
  end

  def test_destroy
    login(alexis)
    evaluation = evaluations(:js2)
    assert_difference("Evaluation.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", id: evaluation.id})
      assert_redirected_to(skill_path(evaluation.skill.community, evaluation.skill))
    end
  end

  def test_destroy_with_exams
    login(alexis)
    evaluation = evaluations(:js2)
    assert(evaluation.start(subscriptions(:js_antoine), "Exam"))
    assert_no_difference("Evaluation.count") do
      delete(:destroy, params: {permalink: "base-secrete", id: evaluation.id})
      assert_redirected_to(skill_path(evaluation.skill.community, evaluation.skill))
    end
  end

  def test_disable_when_author
    evaluation = evaluations(:js)
    login(users(:alexis))
    post(:disable, params: {permalink: "base-secrete", id: evaluation.id})
    assert_redirected_to(skill_path(base, js))
    assert(evaluation.reload.disabled_at)
  end

  def test_disable_when_moderator
    evaluation = evaluations(:js)
    login(users(:antoine))
    memberships(:antoine_base).update!(moderator: true)
    post(:disable, params: {permalink: "base-secrete", id: evaluation.id})
    assert_redirected_to(skill_path(base, js))
    assert(evaluation.reload.disabled_at)
  end

  def test_disable_when_not_allowed
    login(users(:antoine))
    evaluation = evaluations(:js)
    post(:disable, params: {permalink: "base-secrete", id: evaluation.id})
    assert_redirected_to(skill_path(base, js))
    refute(evaluation.reload.disabled_at)
  end

  def test_enable
    (evaluation = evaluations(:js)).touch(:disabled_at)
    login(users(:alexis))
    post(:enable, params: {permalink: "base-secrete", id: evaluation.id})
    assert_redirected_to(skill_path(base, js))
    refute(evaluation.reload.disabled_at)
  end

  def test_show
    (evaluation = evaluations(:js)).touch(:disabled_at)
    login(alexis)
    get(:show, params: {permalink: "base-secrete", id: evaluation.id})
    assert_response(:success)
  end

  def test_new
    login(alexis)
    get(:new, params: {permalink: "base-secrete", skill_id: ror.id})
    assert_response(:success)
  end

  def test_edit_succeeds
    login(alexis)
    evaluation = evaluations(:js2)
    get(:edit, params: {permalink: "base-secrete", id: evaluation.id})
    assert_response(:success)
  end
end
