# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def index?
    user.editor?
  end

  def show?
    user.editor?
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