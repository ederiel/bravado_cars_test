FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    preferred_price_range { generate(:car_price_range) }

    trait :with_preferred_brand do
      transient do
        with_preferred_brand { true }
      end

      after(:create) do |myself, evaluator|
        if evaluator.with_preferred_brand
          myself.preferred_brands << FactoryBot.create(:brand)
        end
      end
    end
  end
end
