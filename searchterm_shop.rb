#!/usr/bin/env ruby

=begin

Name: shopper.rb
Date Created: April 2014
Author: Chris Caruso

Script to crawl supermarket web pages and comparison shop for my frequent purchases.
Currently using Capybara and Selenium, planning to switch to headless browser after
testing completes (although it's fun to watch the automated browsing). Script 
outputs search results to command line but plan to generate table. 

=end

require 'capybara'

#Capybara.run_server = false
Capybara.current_driver = :selenium

pathmark = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
pathmark_prices = Hash.new
superfresh = 'http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf'
superfresh_prices = Hash.new
acme = 'http://acmemarkets.mywebgrocer.com/Circular/Philadelphia-10th-and-Reed/BE0473057/Weekly/2/1'
acme_prices = Hash.new
frogro = 'http://thefreshgrocer.shoprite.com/Circular/The-Fresh-Grocer-of-Walnut/E7E1123699/Weekly/2'
frogro_prices = Hash.new
$prices = []
$meaty_targets = ['Salmon','London Broil','Roast','Chicken Breast']

module Shopper
  class Acme
    include Capybara::DSL
    def get_results(store, pricelist)
    #this one is different....search based
      storename = store[/http:\/\/(.+?)\./,1]
      visit(store)
      page.driver.browser.manage.window.resize_to(1000,1000)
      $meaty_targets.each do |m|
        page.fill_in('Search Weekly Ads', :with => m)
        page.click_button('GO')
        lastpage = page.has_link?('Next Page') ? page.first(:xpath,"//a[contains(@title,'Page')]")[:title][/ of (\d+)/,1].to_i : 0
        page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
          item_name = node.first('img')[:alt]
          item_price = node.first('p').text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
        for i in 2..lastpage
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

  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    def get_results(store,pricelist)
      storename = store[/http:\/\/(.+?)\./,1]
      visit(store)
      $meaty_targets.each do |m|
        page.fill_in('Search Ad', :with => m)
        page.click_button('Search Ad')
#      page.driver.browser.switch_to.frame(0)
#      page.first(:link,'Text Only').click
      #add each loop for categories in arg array
#      page.first(:link,'Meat').click
#      page.first(:link,'View All').click
        num_rows = page.find('span', :text => /Showing items 1-/).text.match(/of (\d+)/).captures
        num_rows[0].to_i.times do |meat|
          item_name =  page.find(:xpath, "//div[@id = 'itemName#{meat}']").text
          item_price = page.find(:xpath, "//td[@id = 'itemPrice#{meat}']").text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
      end
    end
  end

end

def scan_price(storename, item_name, target_item, item_price)
 if item_name =~ /#{target_item}\W+?/ #added \W to eliminate 'roasted' etc.
   puts "#{storename}: #{item_name} for #{item_price}."
   $prices << ["#{storename}","#{item_name}","#{item_price}"]
 end
end

def build_table
  file_loc = '/Users/carusocr/projects/todo/views/table.haml'
  #file_loc = '/home/carusocr/projects/todo/views/table.haml'
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

shop = Shopper::Acme.new
shop.get_results(acme,acme_prices)
build_table