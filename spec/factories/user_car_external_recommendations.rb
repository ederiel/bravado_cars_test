FactoryBot.define do
  factory :user_car_external_recommendation do
    user { create(:user) }
    car { create(:car) }
    rank_score { Random.new.rand(0..1) }
    retrieved_at { DateTime.yesterday }
  end
end
