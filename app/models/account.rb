class Account < ApplicationRecord
  has_many :account_users
  has_many :users, through: :account_users
  has_one :business, dependent: :destroy
  has_one :developer, dependent: :destroy

  accepts_nested_attributes_for :account_users

  def self.build_with_owner(user)
    user.accounts.build(account_users_attributes: [
      {role: :owner, user: user}
    ])
  end
end
