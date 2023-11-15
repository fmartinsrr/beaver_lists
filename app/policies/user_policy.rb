# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.editor? || user.viewer?
  end

  def show?
    user.editor? || user.viewer?
  end

  def edit?
    user.editor?
  end

  def create?
    user.editor?
  end

  def import? 
    false 
  end
end