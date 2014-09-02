# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :events_category, :class => 'EventsCategories' do
    event_id 1
    category_id 1
    pound 1
  end
end
