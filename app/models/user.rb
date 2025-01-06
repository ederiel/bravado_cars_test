class User < ApplicationRecord
  has_many :user_preferred_brands, dependent: :destroy
  has_many :preferred_brands, through: :user_preferred_brands, source: :brand
  has_many :user_car_external_recommendations, dependent: :destroy

  def last_retrieved_at
    user_car_external_recommendations.order(retrieved_at: :desc).first&.retrieved_at
  end
end
