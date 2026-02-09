class Badge::Producer < Badge
  Workspace.after_update { Badge::Producer.trigger(self) }

  def self.trigger(workspace)
    return if !workspace.published_at
    workspace.partnerships.writer.each do |partnership|
      next unless (membership = Membership.where(community: workspace.community_id, user: partnership.user_id).first)
      next if compute_score(membership) < required_count
      next if where(membership: membership).exists?
      create!(membership: membership)
    end
  end

  def self.required_count
    2
  end

  def self.compute_score(membership)
    membership.user.workspaces.where(community: membership.community_id).merge(Workspace::Partnership.writer).published.count
  end

  def self.replay
    Workspace.find_each { |w| trigger(w) }
  end
end
