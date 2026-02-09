class Admin::BaseController < ApplicationController
  before_action :current_user_must_be_admin

  private

  layout "admin"
end
