# config/initializers/high_voltage.rb
HighVoltage.route_drawer = HighVoltage::RouteDrawers::Root

HighVoltage.configure do |config|
  config.home_page = 'home'
end