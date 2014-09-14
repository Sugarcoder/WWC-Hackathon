FactoryGirl.define do
  factory :category do
    sequence(:name) { |n| "categroy_00#{n}" }
  end
end