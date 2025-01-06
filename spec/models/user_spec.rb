require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it "is valid with valid attributes" do
    expect(user).to be_valid
    expect { user.save }.to change { User.count }.by 1
  end

  context "with preferred brands" do
    let (:user) { create(:user, :with_preferred_brand) }
    let (:brand) { create(:brand) }

    it "can access preferred brands" do
      expect(user.preferred_brands.count).to eq 1
    end

    it "accepts new preferred brands" do
      expect { user.preferred_brands << brand }.to change { user.preferred_brands.count }.by 1
    end
  end

  context "without preferred brands" do
    let (:user) { create(:user) }
    let (:brand) { create(:brand) }

    it "has no preferred brands" do
      expect(user.preferred_brands.count).to eq 0
    end

    it "accepts new preferred brands" do
      expect { user.preferred_brands << brand }.to change { user.preferred_brands.count }.by 1
    end
  end
end
