# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, aliases: [:leader] do
    firstname "Normal"
    sequence(:lastname) { |n| "User#{n}" }
    sequence(:username) { |n| "user#{n}" }
    password "secret123"
    sequence(:email)  { |n| "#{username}email#{n}@example.com" }
    telephone '1234567890'
    role 0

    trait :admin do
      firstname "Admin"
      role      1
    end

    trait :super_admin do
      firstname "SuperAdmin"
      role      2
    end
  end
end
