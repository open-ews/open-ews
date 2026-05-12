class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record = nil)
    @user = user
    @record = record
  end

  def index?
    read?
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    manage?
  end

  def create?
    manage?
  end

  def update?
    manage?
  end

  def manage?
    true
  end

  def read?
    true
  end

  private

  def account_owner?
    user.owner?
  end
end
