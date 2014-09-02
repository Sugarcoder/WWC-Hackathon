class EventsCategories < ActiveRecord::Base
  belongs_to :event
  belongs_to :category

  validates :event_id, uniqueness: { scope: :category_id,
    message: "One event can only have one record for one category" }
end
