# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    firstname "Normal"
    sequence(:lastname) { |n| "User#{n}" }
    sequence(:username) { |n| "user#{n}" }
    password "secret123"
    sequence(:email)  { |n| "#{username}email#{n}@example.com" }
    telephone '1234567890'
    role 0

    after(:create) do |user|
      user.confirm!
    end

    trait :confirmed do
      confirmed_at 1.day.ago
    end
  end

  factory :leader, parent: :user do
    firstname "Admin"
    role      1
  end

  factory :super_admin, parent: :user do
    firstname "SuperAdmin"
    role      2
  end

end
