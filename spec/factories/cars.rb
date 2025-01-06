FactoryBot.define do
  factory :car do
    transient do
      make_and_model { Faker::Vehicle.make_and_model.split(" ") }
    end

    model { make_and_model.last }
    brand { create(:brand, name: make_and_model.first) }
    price { generate(:car_price) }
  end
end
