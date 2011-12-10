class HomeController < ApplicationController
  before_filter :check_login

  def index
  end
end
