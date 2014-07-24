class Event < ActiveRecord::Base
  belongs_to :category

  def starting_date
    return nil if self.starting_time.nil?
    self.starting_time.strftime('%m/%d/%Y') 
  end

  def ending_date
    return nil if self.ending_time.nil?
    self.ending_time.strftime('%m/%d/%Y') 
  end

  def starting_hour
    return nil if self.starting_time.nil?
    self.starting_time.strftime('%l:%M %p')
  end

  def ending_hour
    return nil if self.ending_time.nil?
    self.ending_time.strftime('%l:%M %p')
  end

  def waiting_list_slot
    self.slot.to_i/2 + 1
  end

end
