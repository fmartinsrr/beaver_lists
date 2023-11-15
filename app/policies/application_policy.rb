# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.editor?
  end

  def new?
    user.editor?
  end

  def update?
    user.editor?
  end

  def edit?
    update?
  end

  def destroy?
    user.editor?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    private

    attr_reader :user, :scope
  end

  def dashboard?
    true
  end

  def export?
    user.editor?
  end

  def history?
    user.editor? || user.viewer?
  end

  def show_in_app?
    true
  end

end
