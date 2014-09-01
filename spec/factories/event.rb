FactoryGirl.define do
  factory :event do
    title "test event"
    slot  "5"
    description "This is a test event description"
    is_finished false
    starting_time Time.now + 2.hours
    ending_time Time.now + 3.hours
    leader_id 1
    category
    location
  end
end