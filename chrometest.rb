require 'capybara'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.javascript_driver = :chrome
Capybara.current_driver = :chrome   #should this be current or default? Explore reasons.

include Capybara::DSL

@pathmark = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
@superfresh = 'http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf'
@acme = 'http://acmemarkets.mywebgrocer.com/Circular/Philadelphia-10th-and-Reed/BE0473057/Weekly/2/1'
@frogro = 'http://thefreshgrocer.shoprite.com/Circular/The-Fresh-Grocer-of-Walnut/E7E1123699/Weekly/2'
