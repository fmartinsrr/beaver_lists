# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit
  
  def pundit_user
    current_admin
  end
end