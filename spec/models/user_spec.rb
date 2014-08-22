require 'rails_helper'

RSpec.describe User, :type => :model do
  context ".full_name" do
    it "eqauls to firstname + space + lastname" do
      user = build(:user)
      expect(user.full_name).to eq user.firstname + " " + user.lastname
    end
  end
end
