require "rails_helper"

RSpec.describe Car, type: :model do
  let(:car) { build(:car) }

  it "is valid with valid attributes" do
    expect(car).to be_valid
    expect { car.save }.to change { Car.count }.by 1
  end

  context "when created normally" do
    let (:car) { create(:car) }
    let (:brand) { create(:brand) }

    it "can access brand" do
      expect(car.brand.present?).to be true
    end
  end
end
