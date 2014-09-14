FactoryGirl.define do
  factory :location do
    sequence(:name) { |n| "place_00#{n}" }
  end
end