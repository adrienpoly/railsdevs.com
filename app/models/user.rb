class User < ApplicationRecord
  devise :confirmable,
    :database_authenticatable,
    :recoverable,
    :registerable,
    :rememberable,
    :validatable
  pay_customer

  has_many :notifications, as: :recipient, dependent: :destroy
  has_one :business, dependent: :destroy
  has_one :developer, dependent: :destroy

  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users, autosave: true

  has_many :conversations, ->(user) {
    unscope(where: :user_id)
      .left_joins(:business, :developer)
      .where("businesses.user_id = ? OR developers.user_id = ?", user.id, user.id)
      .visible
  }

  scope :admin, -> { where(admin: true) }

  before_destroy :mark_accounts_for_destruction

  def pay_customer_name
    business&.name
  end

  def active_business_subscription?
    subscriptions.active.any?
  end

  def active_legacy_business_subscription?
    legacy_plan = BusinessSubscription::Legacy.new
    subscriptions.for_name(legacy_plan.name).active.any?
  end

  private

  def mark_accounts_for_destruction
    accounts.map(&:mark_for_destruction)
  end
end
