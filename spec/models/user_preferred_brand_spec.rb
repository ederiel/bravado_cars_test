require "rails_helper"

RSpec.describe UserPreferredBrand, type: :model do
  let(:user_preferred_brand) { build(:user_preferred_brand) }

  it "is valid with valid attributes" do
    expect(user_preferred_brand).to be_valid
    expect { user_preferred_brand.save }.to change { described_class.count }.by 1
  end

  context "with a user and a brand" do
    let (:user) { create(:user) }
    let (:brand) { create(:brand) }
    let (:user_preferred_brand) { create(:user_preferred_brand, user: user, brand: brand) }

    it "can access brand" do
      expect(user_preferred_brand.brand.present?).to be true
      expect(user_preferred_brand.brand).to eq brand
    end

    it "can access user" do
      expect(user_preferred_brand.user.present?).to be true
      expect(user_preferred_brand.user).to eq user
    end
  end
end
