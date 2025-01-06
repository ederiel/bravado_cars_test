require "rails_helper"

RSpec.describe UserCarExternalRecommendation, type: :model do
  let(:user_car_external_recommendation) { build(:user_car_external_recommendation) }

  it "is valid with valid attributes" do
    expect(user_car_external_recommendation).to be_valid
    expect(user_car_external_recommendation.rank_score).to be_between(0, 1)
    expect do
      user_car_external_recommendation.save
    end.to change { described_class.count }.by 1
  end

  context "when created normally" do
    let (:user) { create(:user) }
    let (:car) { create(:car) }

    let (:user_car_external_recommendation) do
      create(:user_car_external_recommendation, user: user, car: car)
    end

    it "can access user" do
      expect(user_car_external_recommendation.user.present?).to be true
      expect(user_car_external_recommendation.user).to eq user
    end

    it "can access car" do
      expect(user_car_external_recommendation.car.present?).to be true
      expect(user_car_external_recommendation.car).to eq car
    end
  end
end
