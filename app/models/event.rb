class Event < ActiveRecord::Base
  belongs_to :category

  def starting_date
    return nil if @event.starting_time.nil?
    @event.starting_time.strftime('%m/%d/%Y') 
  end

  def starting_hour
    return nil if @event.starting_time.nil?
    @event.starting_time.strftime('%I:%M %p')
  end
end
