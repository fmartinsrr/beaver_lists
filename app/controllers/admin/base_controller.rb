# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit
  
  def pundit_user
    current_admin
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to dashboard_path
  end
end