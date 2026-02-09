class WorkspaceForm
  attr_reader :result, :workspace

  def self.create(params)
    new.tap { |f| f.create(params) }
  end

  def create(params)
    owner = params.delete(:owner)
    @workspace = Workspace.new(params)
    @workspace.write_attribute(:title, default_params[:title])
    @workspace.write_attribute(:writing, default_params[:writing])
    @workspace.versions.new(default_params)
    workspace.partnerships.new(user: owner, is_owner: true)
    @result = workspace.save
  end

  def default_params
    {
      number: 1,
      title: I18n.t("activerecord.attributes.workspace.default.title"),
      writing: ""
    }
  end
end
