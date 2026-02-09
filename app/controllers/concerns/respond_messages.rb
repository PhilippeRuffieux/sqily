module RespondMessages
  extend ActiveSupport::Concern

  def filter_messages(scope)
    scope = scope.id_below(params[:before]).latest if params[:before]
    # scope = scope.created_after(params[:after]).oldest if params[:after]
    scope = scope.id_above(params[:after]).oldest if params[:after]
    scope = scope.created_from(params[:from]).oldest if params[:from]
    # scope = scope.created_to(params[:to]).latest if params[:to]
    scope = scope.id_to(params[:to]).latest if params[:to]
    scope = scope.latest if !params[:after] && !params[:before]
    scope = scope.not_deleted if !moderator?
    scope = scope.pinned if params[:pinned]
    scope.by_hash_tags(params[:hash_tag])
  end
end
