class Brand < ApplicationRecord
  has_many :cars, dependent: :destroy
  has_many :user_preferred_brands, dependent: :destroy
  has_many :preferred_by_users, through: :user_preferred_brands, source: :user
end
