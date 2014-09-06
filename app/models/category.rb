class Category < ActiveRecord::Base
  has_many :events
  has_many :events_categories, foreign_key: 'category_id', class_name: 'EventsCategories'
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def total_pounds_within_range(date_range)
    self.events_categories.where(created_at: date_range).map(&:pound).inject(0, :+)
  end

  def pounds_per_day_within_range(date_range)
    hash = self.events_categories.where(created_at: date_range).group_by{ |e| e.created_at.strftime("%-m-%-e") }
    hash.each { |k, v|  hash[k] = v.map(&:pound).inject(0, :+) }
  end

end
