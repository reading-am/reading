# encoding: utf-8
class HomeController < ApplicationController
  before_filter :check_login

  def index
  end
end
