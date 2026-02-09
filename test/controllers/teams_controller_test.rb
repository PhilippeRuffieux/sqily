require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  def test_new_as_membership
    login(antoine)
    get(new_team_path(base))
    assert_response(:forbidden)
  end

  def test_new_as_moderator
    login(alexis)
    get(new_team_path(base))
    assert_response(:success)
  end

  def test_create
    login(alexis)

    assert_difference("base.teams.count") do
      post(teams_path(base), params: {team: {name: "New team"}, user_ids: [alexis.id]})
      assert_response(:redirect)
    end

    assert_equal([alexis], Team.last.users)
  end

  def test_create_with_error
    login(alexis)
    assert_no_difference("base.teams.count") do
      post(teams_path(base), params: {team: {name: ""}})
      assert_response(:success)
    end
  end

  def test_edit
    login(alexis)
    get(edit_team_path(base, teams(:backend)))
    assert_response(:success)
  end

  def test_update
    team = teams(:backend)
    login(alexis)
    patch(team_path(base, team), params: {team: {name: "New name"}})
    assert_response(:redirect)
    assert_equal("New name", team.reload.name)
  end

  def test_update_with_error
    team = teams(:backend)
    login(alexis)
    patch(team_path(base, team), params: {team: {name: ""}})
    assert_response(:success)
  end

  def test_delete
    login(alexis)
    assert_difference("Team.count", -1) do
      delete(team_path(base, teams(:backend)))
      assert_response(:redirect)
    end
  end
end
