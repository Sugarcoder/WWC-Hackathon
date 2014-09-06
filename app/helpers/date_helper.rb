module DateHelper
  
  def months_of_current_year
    current_year = Date.today.year
    result = []
    (1..12).each { |month| result << Date.new(current_year, month) }
    result
  end

end
