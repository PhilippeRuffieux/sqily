module TeamsHelper
  def teamates_options_to_json(team)
    team.users.order(:name).pluck(:id, :name).map { |row| {id: row[0], name: row[1]} }.to_json
  end

  def available_teamates_options_to_json
    current_community.users.by_team(nil).order(:name).pluck(:id, :name).map { |row| {id: row[0], name: row[1]} }.to_json
  end
end
