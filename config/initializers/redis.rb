if ENV["REDISTOGO_URL"]
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
else
  if Rails.env.test?
    $redis = Redis.new(db: 3)
  else
    $redis = Redis.new(db: 2)
  end
end