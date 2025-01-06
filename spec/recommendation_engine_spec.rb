require "rails_helper"

RSpec.describe RecommendationEngine do
  describe ".recommend_cars" do
    subject do
      described_class.recommend_cars(
        user: user,
        price_min: price_min,
        price_max: price_max,
        matching_brand: matching_brand,
        page_size: page_size,
        page_number: page_number
      )
    end

    let(:obsolete_brand_name) { "Studebaker" }

    let(:user) { create(:user) }
    let(:price_min) { nil }
    let(:price_max) { nil }
    let(:page_size) { nil }
    let(:page_number) { nil }
    let(:matching_brand) { nil }

    let(:recommended_cars) { subject }

    context "with invalid user" do
      let(:user) { nil }
      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with invalid price range" do
      let(:price_min) { 40_000 }
      let(:price_max) { 10_000 }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with invalid page number" do
      let(:page_number) { 0 }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with invalid page size" do
      let(:page_size) { 0 }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with a brand search string" do
      let(:matching_brand) { brand.name[..-2] }  # drop last character to make search string
      let(:brand) { car.brand }
      let(:car) { create(:car, model: model, brand: create(:brand, name: brand_name)) }
      let(:brand_name) { make_and_model.first }
      let(:model) { make_and_model.second }
      let(:make_and_model) { Faker::Vehicle.make_and_model.split(" ") }

      context "when the brand is present" do
        it "returns a match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when the brand is not present" do
        let(:brands) { [brand, create(:brand, name: obsolete_brand_name)] }
        let(:wrong_brand) { brands.second }
        let(:matching_brand) { wrong_brand.name[..-2] }

        it "returns no matches" do
          expect(recommended_cars.count).to eq 0
        end
      end
    end

    context "with a price minimum" do
      let(:price_min) { car.price / 2 }
      let(:car) { create(:car) }

      context "when a car above that price is present" do
        it "returns a match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when a car at that price is present" do
        let(:price_min) { car.price }

        it "returns a match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when a car above that price is not present" do
        let(:price_min) { car.price * 2 }

        it "returns no matches" do
          expect(recommended_cars.count).to eq 0
        end
      end
    end

    context "with a price maximum" do
      let(:price_max) { car.price * 2 }
      let(:car) { create(:car) }

      context "when a car below that price is present" do
        it "returns a match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when a car at that price is present" do
        let(:price_max) { car.price }

        it "returns a match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when a car above that price is not present" do
        let(:price_max) { car.price / 2 }

        it "returns no matches" do
          expect(recommended_cars.count).to eq 0
        end
      end
    end

    context "with a price range" do
      let(:price_max) { cars.first.price * 2 }
      let(:price_min) { cars.second.price / 2 }

      let(:cars) do
        [
          create(:car, price: first_price),
          create(:car, price: second_price)
        ]
      end

      let(:first_price) { 30_000 }
      let(:second_price) { 40_000 }

      context "when cars within that range are present" do
        it "returns a match" do
          expect(recommended_cars.count).to eq 2
        end
      end

      context "when one car within that range is present" do
        let(:price_max) { 35_000 }

        it "returns only one match" do
          expect(recommended_cars.count).to eq 1
        end
      end

      context "when no cars within that range are present" do
        let(:second_price) { first_price }
        let(:price_max) { cars.first.price * 2 }
        let(:price_min) { cars.second.price * 1.5 }

        it "returns no matches" do
          expect(recommended_cars.count).to eq 0
        end
      end
    end

    context "with preferred brands" do
      let(:non_preferred_brand) { create(:brand, name: obsolete_brand_name) }

      context "with no preferred price range" do
        let(:user) do
          create(:user,
            preferred_brands: [cars.second.brand],
            preferred_price_range: nil
          )
        end

        let(:cars) do
          [
            create(:car, brand: non_preferred_brand),
            create(:car)
          ]
        end

        it "orders preferred brands first" do
          expect(recommended_cars.first).to eq cars.second
        end

        it "orders non-preferred brands second" do
          expect(recommended_cars.second).to eq cars.first
        end

        it "labels preferred brand as 2" do
          expect(recommended_cars.first.label).to eq 2
        end

        it "labels non-preferred brand as 0" do
          expect(recommended_cars.second.label).to eq 0
        end
      end

      context "with a preferred price range" do
        let(:user) do
          create(:user,
            preferred_brands: [cars.fourth.brand, cars.first.brand],
            preferred_price_range: (15_000..40_000)
          )
        end

        let(:cars) do
          [
            create(:car, price: 70_000),
            create(:car, brand: non_preferred_brand, price: 20_000),
            create(:car, brand: non_preferred_brand, price: 60_000),
            create(:car, price: 30_000)
          ]
        end

        it "orders preferred brands within preferred price range first" do
          expect(recommended_cars.first).to eq cars.fourth
        end

        it "orders preferred brands outside preferred price range second" do
          expect(recommended_cars.second).to eq cars.first
        end

        it "orders non-preferred brands last" do
          last_cars = [recommended_cars.third, recommended_cars.last]
          expected_cars = [cars.second, cars.third]

          expect(last_cars).to match_array expected_cars
        end

        it "labels preferred brand within preferred price range as 2" do
          expect(recommended_cars.first.label).to eq 2
        end

        it "labels preferred brand outside preferred price range as 1" do
          expect(recommended_cars.second.label).to eq 1
        end

        it "labels non-preferred brand as 0" do
          expect(recommended_cars.third.label).to eq 0
          expect(recommended_cars.last.label).to eq 0
        end
      end
    end

    context "with rank scores" do
      let(:user) do
        create(:user,
          user_car_external_recommendations: [
            create(:user_car_external_recommendation,
              car: cars.second,
              rank_score: low_rank_score
            ),
            create(:user_car_external_recommendation,
              car: cars.third,
              rank_score: high_rank_score
            )
          ],
          preferred_price_range: nil,
          preferred_brands: []
        )
      end

      let(:high_rank_score) { 0.9 }
      let(:low_rank_score) { 0.2 }
      let(:high_price) { 60_000 }
      let(:low_price) { 20_000 }

      let(:cars) do
        [
          create(:car, price: high_price),
          create(:car, price: low_price),
          create(:car, price: low_price),
          create(:car, price: low_price)
        ]
      end

      it "orders high rank scores above low rank scores" do
        expect(recommended_cars.first).to eq cars.third
        expect(recommended_cars.second).to eq cars.second
      end

      it "orders low price above high price" do
        expect(recommended_cars.third).to eq cars.fourth
        expect(recommended_cars.last).to eq cars.first
      end
    end
  end
end
