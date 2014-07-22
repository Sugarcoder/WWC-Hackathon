json.array!(@events) do |event|
  json.extract! event, :id, :title, :starting_time, :ending_time, :date, :slot, :slot_remaing, :address, :location_id, :description, :is_recurring, :category_id
  json.url event_url(event, format: :json)
end
