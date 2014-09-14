FactoryGirl.define do
  factory :event do
    title "test event"
    description "This is a test event description"
    slot  5
    is_finished false
    starting_time Time.current + 10.hours
    ending_time Time.current + 11.hours
    attending_user_count 0
    waiting_user_count 0
    leader_id 100
  end
end