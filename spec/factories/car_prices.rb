FactoryBot.define do
  sequence(:car_price) { Random.new.rand(1_000..60_000) }
  sequence(:car_price_range) { (Random.new.rand(20_000)..Random.new.rand(20_000..60_000)) }
end
