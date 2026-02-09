ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start do
  minimum_coverage 93.63
  add_filter("/lib/")
  add_filter("/test/")
  add_filter("/initializers/")
end

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

require "mocha/minitest"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include ActionMailer::TestHelper

  def login(user)
    ApplicationController.any_instance.stubs(current_user: user) && user
  end

  def login_as_admin
    login(admin)
  end

  def base
    @base ||= communities(:base)
  end

  def hep
    @hep ||= communities(:hep)
  end

  def alexis
    @alexis ||= users(:alexis)
  end

  def antoine
    @antoine ||= users(:antoine)
  end

  def admin
    @admin ||= users(:admin)
  end

  def valentin
    @valentin ||= users(:valentin)
  end

  def js
    @js ||= skills(:js)
  end

  def html
    @html ||= skills(:html)
  end

  def css
    @css ||= skills(:css)
  end

  def ror
    @ror ||= skills(:ror)
  end

  def js_demo
    @js_demo ||= events(:js_demo)
  end
end
