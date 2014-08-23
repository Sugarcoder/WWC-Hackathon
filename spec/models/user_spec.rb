require 'rails_helper'

RSpec.describe User, :type => :model do
  context "#full_name" do
    it "eqauls to firstname + space + lastname" do
      user = build(:user, firstname: 'Lu', lastname: 'Xiao')
      expect(user.full_name).to eq 'Lu Xiao'
    end
  end
end
