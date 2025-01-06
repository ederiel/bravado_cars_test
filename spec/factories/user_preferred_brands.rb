FactoryBot.define do
  factory :user_preferred_brand do
    user { create(:user) }
    brand { create(:brand) }
  end
end
