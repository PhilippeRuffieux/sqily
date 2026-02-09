class PagesController < ApplicationController
  layout "public"

  def show
    @page = Page.find_by(slug: params[:slug].downcase)
    render_not_found unless @page
  end
end
