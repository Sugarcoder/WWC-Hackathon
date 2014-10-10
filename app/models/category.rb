class Category < ActiveRecord::Base
  has_many :events
  has_many :events_categories, foreign_key: 'category_id', class_name: 'EventsCategories'
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def total_pounds_within_range(starting_date, ending_date)
    sponsorships = sponsorship_within_range(starting_date, ending_date)
    sponsorships.map(&:pound).inject(0, :+)
  end

  def pounds_per_day_within_range(starting_date, ending_date)
    sponsorships = sponsorship_within_range(starting_date, ending_date)
    hash = sponsorships.order('starting_time ASC').group_by{ |e| e.event_starting_time.strftime("%-m-%-e") }
    hash.each { |k, v|  hash[k] = v.map(&:pound).inject(0, :+) }
  end

  def sponsorship_within_range(starting_date, ending_date)
    EventsCategories.joins(:event).where('events_categories.category_id = ? AND starting_time BETWEEN ? AND ?', self.id, starting_date, ending_date + 1.day)
  end

end
