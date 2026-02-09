class Admin::PagesController < Admin::BaseController
  before_action :find_page, only: %i[show update destroy]

  def index
    @pages = Page.page(params[:page]).order(:title, :created_at)
  end

  def create
    @page = Page.new(page_attributes)
    if @page.save
      redirect_to(admin_page_path(@page), notice: "Page crée.")
    else
      render(:new)
    end
  end

  def new
    @page = Page.new
  end

  def show
  end

  def update
    if @page.update(page_attributes)
      redirect_to(admin_page_path(@page), notice: "Page mise à jour.")
    else
      render(:show)
    end
  end

  def destroy
    @page.destroy
    redirect_to(admin_pages_path)
  end

  private

  def find_page
    @page = Page.find(params[:id])
  end

  def page_attributes
    params.require(:page).permit(:slug, :title, :content)
  end
end
