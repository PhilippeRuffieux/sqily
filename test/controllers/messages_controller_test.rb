require "test_helper"

class MessagesControllerTest < ActionController::TestCase
  def setup
    Message::Upload.any_instance.stubs(:save_file)
  end

  def test_index_to_a_user
    login(alexis = users(:alexis))
    get(:index, params: {permalink: "base-secrete", user_id: antoine = users(:antoine)})
    assert_response(:success)
    assert_equal(0, Message.from_user(antoine).to_user(alexis).unread.count)
  end

  def test_index_to_a_user_retrieve_edited_messages
    login(users(:alexis))
    message = messages(:antoine_to_alexis)
    message.update(created_at: 1.day.ago, edited_at: 1.minute.from_now)
    get(:index, format: "json", params: {permalink: "base-secrete", user_id: users(:antoine).id, after: message.id})
    assert_response(:success)
    assert(JSON.parse(@response.body)["edited_messages"])
  end

  def test_index_to_a_community
    login(antoine)
    before_request = Time.now
    get(:index, xhr: true, params: {permalink: "base-secrete", format: "json"})
    assert_response(:success)
    json = JSON.parse(@response.body)
    assert(json["new_messages"])
    assert_equal([skills(:js).id], json["skill_ids_with_unread_messages"])
    assert(before_request < memberships(:antoine_base).last_read_at)
  end

  def test_index_to_a_community_does_not_log_page_view
    login(antoine)
    assert_no_difference("PageView.count") do
      get(:index, xhr: true, params: {permalink: "base-secrete", format: "json"})
      assert_response(:success)
    end
  end

  def test_index_to_a_community_retrieve_edited_messages
    login(users(:antoine))
    message = messages(:alexis_to_base)
    message.update(created_at: 1.day.ago, edited_at: 1.minute.from_now)
    get(:index, xhr: true, params: {permalink: "base-secrete", after: message.id, format: "json"})
    assert_response(:success)
    assert(JSON.parse(@response.body)["edited_messages"])
  end

  def test_index_to_a_skill
    login(users(:antoine))
    before_request = Time.now
    get(:index, xhr: true, params: {permalink: "base-secrete", skill_id: skills(:js)})
    assert(subscriptions(:js_antoine).last_read_at > before_request)
    assert_response(:success)
  end

  def test_index_to_a_skill_retrieve_edited_messages
    login(users(:antoine))
    message = messages(:alexis_to_js)
    message.update(created_at: 1.day.ago, edited_at: 1.minute.from_now)
    get(:index, xhr: true, params: {permalink: "base-secrete", skill_id: skills(:js).id, after: message.id, format: "json"})
    assert_response(:success)
    assert(JSON.parse(@response.body)["edited_messages"])
  end

  def test_index_when_user_is_not_community_member
    login(users(:antoine))
    get(:index, xhr: true, params: {permalink: "hep"})
    assert_response(:not_found)
  end

  def test_index_when_user_is_not_subscribed_to_skill
    login(users(:antoine))
    get(:index, xhr: true, params: {permalink: "base-secrete", skill_id: skills(:ror).id})
    assert_response(:not_found)
  end

  def test_create_to_user
    login(alexis)
    assert_difference("Message.between(alexis, antoine).count") do
      post(:create, params: {permalink: "base-secrete", message: {to_user_id: antoine.id, text: "Test"}})
      assert_redirected_to(messages_path(base, user_id: antoine.id))
    end
  end

  def test_create_to_community
    login(alexis)
    assert_difference("Message.to_community(base).count") do
      post(:create, params: {permalink: "base-secrete", message: {to_community_id: base.id, text: "Test"}})
      assert_redirected_to(skills_path(base))
    end
  end

  def test_create_to_skill
    login(alexis)
    assert_difference("Message.to_skill(ror).count") do
      post(:create, params: {permalink: "base-secrete", message: {to_skill_id: ror.id, text: "Test"}})
      assert_redirected_to(messages_skill_path(base, ror))
    end
  end

  def test_create_to_workspace
    workspace = workspaces(:ror_development)
    login(alexis)
    assert_difference("Message.to_workspace(workspace).count") do
      post(:create, params: {permalink: "base-secrete", message: {to_workspace_id: workspace.id, text: "Test"}})
      assert_redirected_to(workspace_path(base, workspace))
    end
  end

  def test_create_xhr
    alexis, _ = users(:alexis), users(:antoine)
    login(alexis)
    assert_difference("Message.between(alexis, antoine).count") do
      post(:create, xhr: true, params: {permalink: "base-secrete", message: {to_user_id: users(:antoine).id, text: "Test"}})
      assert_response(:success)
    end
  end

  def test_create_when_user_is_not_community_member
    login(users(:antoine))
    post(:create, xhr: true, params: {permalink: "hep", message: {to_community_id: communities(:hep).id, text: "Test"}})
    assert_response(:not_found)
  end

  def test_create_when_user_is_not_subscribed_to_skill
    login(users(:antoine))
    post(:create, xhr: true, params: {permalink: "base-secrete", message: {to_skill_id: skills(:ror).id, text: "Test"}})
    assert_response(:not_found)
  end

  def test_update
    login(users(:alexis))
    message = messages(:alexis_to_base)
    put(:update, xhr: true, params: {permalink: "base-secrete", id: message.id, message: {text: "NEW TEXT"}})
    assert_response(:success)
    assert_equal("NEW TEXT", message.reload.text)
    assert(message.edited_at)
  end

  def test_upload_to_community
    login(users(:alexis))
    community = communities(:base)
    file = fixture_file_upload("image.jpg", "image/jpeg")
    assert_difference("Message::Upload.count") do
      post(:upload, params: {permalink: "base-secrete", upload: {text: "Test", file: file, to_community_id: community.id}})
      assert_redirected_to(skills_path(base))
    end
  end

  def test_upload_to_skill
    login(users(:alexis))
    skill = skills(:ror)
    file = fixture_file_upload("image.jpg", "image/jpeg")
    assert_difference("Message::Upload.count") do
      post(:upload, params: {permalink: "base-secrete", upload: {text: "Test", file: file, to_skill_id: skill.id}})
      assert_redirected_to("/base-secrete/skills/#{skill.id}/messages")
    end
  end

  def test_upload_to_user
    login(users(:alexis))
    user = users(:antoine)
    file = fixture_file_upload("image.jpg", "image/jpeg")
    assert_difference("Message::Upload.count") do
      post(:upload, params: {permalink: "base-secrete", upload: {text: "Test", file: file, to_user_id: user.id}})
      assert_redirected_to("/base-secrete/messages?user_id=#{user.id}")
    end
  end

  def test_upload_to_workspace
    login(alexis)
    workspace = workspaces(:ror_development)
    file = fixture_file_upload("image.jpg", "image/jpeg")
    assert_difference("Message::Upload.count") do
      post(:upload, params: {permalink: "base-secrete", upload: {text: "Test", file: file, to_workspace_id: workspace.id}})
      assert_redirected_to(workspace_path(base, workspace))
    end
  end

  def test_unread_message
    login(users(:alexis))
    (msg = messages(:antoine_to_alexis)).touch(:read_at)
    assert_difference("Message.unread.count") do
      post(:unread, params: {permalink: "base-secrete", id: msg.id})
      assert_response(:redirect)
    end
  end

  def test_pin
    login(users(:alexis))
    assert_difference("Message.pinned.count") do
      post(:pin, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_pin_when_not_moderator
    login(users(:antoine))
    assert_no_difference("Message.pinned.count") do
      post(:pin, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_vote
    login(users(:alexis))
    assert_difference("Vote.count") do
      post(:vote, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_delete_when_message_belongs_to_current_user
    login(users(:alexis))
    assert_difference("Message.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_delete_when_message_does_not_belong_to_author
    login(users(:antoine))
    assert_no_difference("Message.count") do
      delete(:destroy, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_delete_when_current_user_is_moderator
    login(users(:antoine))
    memberships(:antoine_base).update!(moderator: true)
    assert_difference("Message.count", -1) do
      delete(:destroy, params: {permalink: "base-secrete", id: messages(:alexis_to_base).id})
      assert_response(:redirect)
    end
  end

  def test_download
    login(users(:alexis))
    message = messages(:alexis_file_to_ror)
    assert_difference("message.reload.download_count") do
      get(:download, params: {permalink: "base-secrete", id: message.id})
      assert_redirected_to(message.file_url)
    end
  end

  def test_download_when_user_does_not_belong_to_community
    login(users(:antoine))
    message = messages(:alexis_file_to_ror)
    get(:download, params: {permalink: "base-secrete", id: message.id})
    assert_response(:not_found)
  end

  def test_search
    login(alexis)
    get(:search, params: {permalink: base, query: "javascript"})
    assert_response(:success)
  end

  def test_search_form
    login(alexis)
    get(:search_form, params: {permalink: base, query: "javascript"})
    assert_response(:success)
  end
end
