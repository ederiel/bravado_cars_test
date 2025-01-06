class Car < ApplicationRecord
  belongs_to :brand
  has_many :user_car_external_recommendations, dependent: :destroy
end
