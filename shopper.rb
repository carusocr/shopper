#!/usr/bin/env ruby

=begin

Name: shopper.rb
Author: Chris Caruso

Script to crawl supermarket web pages and comparison shop for my frequent purchases.
=end

require 'capybara'
require 'pry'

=begin
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.javascript_driver = :chrome
Capybara.default_driver = :chrome   #should this be current or default? Explore reasons.
=end
Capybara.register_driver :selenium_firefox do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end
Capybara.javascript_driver = :selenium_firefox
Capybara.default_driver = :selenium_firefox   #should this be current or default? Explore reasons.

safeway = 'http://plan.safeway.com/Circular/Seattle-2201-E-Madison-St-/2E2374900/Weekly/2'
safeway_prices = Hash.new
qfc = 'https://www.qfc.com/weeklyad?StoreCode=00847&DivisionId=705'
qfc_prices = Hash.new

$prices = []
$meaty_targets = ['Salmon','London Broil','Roast','Sardines','Chicken Breast']

module Shopper
  
  class QFC
    include Capybara::DSL #figure out how to avoid this
    def get_results(store,pricelist)
      storename = 'QFC'
      visit store
      page.driver.browser.switch_to.frame(0)
      page.execute_script "wishabi.app.gotoGridView()"
      $meaty_targets.each do |m|
        page.all(:xpath,"//li[@class='item']").each do |node|
          #clean these up!
          item_name = node.first(:xpath,"./div[@class='item-name']").text
          item_price = node.first(:xpath,"./div[@class='item-price']").text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
      end
    end
  end

  class Safeway
    include Capybara::DSL
    def get_results(store, pricelist)
      storename = 'Safeway'
      visit(store)
      page.driver.browser.manage.window.resize_to(1000,1000)
      $meaty_targets.each do |m|
        page.fill_in("Search Weekly", :with => m) # works for both "Search Weekly Ads/Circular"
        page.click_button('GO')
        lastpage = page.has_link?('Next Page') ? page.first(:xpath,"//a[contains(@title,'Page')]")[:title][/ of (\d+)/,1].to_i : 0
        page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
          item_name = node.first('img')[:alt]
          item_price = node.first('p').text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
        for i in 2..lastpage
          sleep 1
          page.first(:link,"Next Page").click
          page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
            #(continue assembling hash of prices here)
            item_name = node.first('img')[:alt]
            item_price = node.first('p').text
            pricelist["#{item_name}"] = item_price
            scan_price(storename, item_name, m, item_price)
          end
        end
      end

    end

 
  end

end

def scan_price(storename, item_name, target_item, item_price)
 if item_name =~ /#{target_item} ?/ #added \W to eliminate 'roasted' etc.
   puts "#{storename}: #{item_name} for #{item_price}."
   $prices << ["#{storename}","#{item_name}","#{item_price}"]
 end
end

def build_table
  file_loc = '/Users/carusocr/projects/todo/views/table.haml'
  file = File.open(file_loc,'w')
  file.write("%link{:href => 'style.css', :rel => 'stylesheet'}\n")
  file.write("%table#shoplist\n")
  file.write("  %tbody\n")
  file.write("    %tr\n")
  file.write("    %th Store\n")
  file.write("    %th Item\n")
  file.write("    %th Price\n")
  $prices.each do |row|
    store = row[0]
    file.write("    %tr.#{store}\n")
    row.each do |col|  
      file.write("      %td= '#{col.sub('\'','`')}'\n")
    end
  end
  file.write("%br\n%a{:href => '/present'}\n")
  file.write("  %button\n")
  file.write("    Home\n")
end

shop = Shopper::QFC.new
shop.get_results(qfc,qfc_prices)
shop = Shopper::Safeway.new
shop.get_results(safeway,safeway_prices)
build_table
