require "test_helper"

class Evaluations::DraftsControllerTest < ActionDispatch::IntegrationTest
  def test_create
    login(antoine)
    (subscription = subscriptions(:js_antoine)).draft.destroy
    attributes = {subscription_id: subscription.id, content: "Text", evaluation_id: evaluations(:js2).id}

    assert_difference("Evaluation::Draft.count") do
      post(evaluation_drafts_path(permalink: base), params: {evaluation_draft: attributes})
      assert_response(:success)
    end

    assert_no_difference("Evaluation::Draft.count") do
      post(evaluation_drafts_path(permalink: base), params: {evaluation_draft: attributes})
      assert_response(:success)
    end
  end

  def test_create_into_someone_else_subscription
    login(antoine)
    attributes = {subscription_id: subscriptions(:js_alexis).id, content: "Text"}

    assert_no_difference("Evaluation::Draft.count") do
      post(evaluation_drafts_path(permalink: base), params: {evaluation_draft: attributes})
      assert_response(:unprocessable_entity)
    end
  end
end
