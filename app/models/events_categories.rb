class EventsCategories < ActiveRecord::Base
  belongs_to :event
  belongs_to :category

  delegate :name, to: :category, prefix: true, allow_nil: true
  delegate :starting_time, to: :event, prefix: true, allow_nil: true

  validates :event_id, uniqueness: { scope: :category_id,
    message: "One event can only have one record for one category" }
end
