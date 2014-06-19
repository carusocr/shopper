#!/usr/bin/env ruby

# Working on a script that crawls supermarket pages and comparison shops for me.
# Currently working for AP Supermarkets sites: SuperFresh and Pathmark.
# Acme and Fresh Grocer have sites that require navigating multiple pages and don't
# have text-only versions. Try scraping 1..max pages of subsection, collect items+prices
# in hash, then apply same search.

require 'capybara'
require 'capybara/poltergeist'

require 'capybara/dsl'
Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = "http://www.google.com"

pathmark = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
pathmark_prices = Hash.new
superfresh = 'http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf'
superfresh_prices = Hash.new
acme = 'http://acmemarkets.mywebgrocer.com/Circular/Philadelphia-10th-and-Reed/BE0473057/Weekly/2/1'
acme_prices = Hash.new
$meaty_targets = ['Chicken Breast','London Broil','Roast']

module Shopper
  include Capybara::DSL
  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    def get_results(store,pricelist)
      storename = store[/http:\/\/(.+?)\./,1]
      visit(store)
      sleep 1
      page.driver.browser.switch_to.frame(0)
      sleep 1
      page.first(:link,'Text Only').click
      sleep 1
			#add each loop for categories in arg array
      page.first(:link,'Meat').click
			sleep 1
      page.first(:link,'View All').click
			sleep 1
			# added to test window resizing
			page.driver.browser.manage.window.resize_to(800,800)
      num_rows = page.find('span', :text => /Showing items 1-/).text.match(/of (\d+)/).captures
      num_rows[0].to_i.times do |meat|
        item_name =  page.find(:xpath, "//div[@id = 'itemName#{meat}']").text
        item_price = page.find(:xpath, "//td[@id = 'itemPrice#{meat}']").text
        pricelist["#{item_name}"] = item_price
        $meaty_targets.each do |m|
          if item_name =~ /#{m}/
           puts "Found #{item_name} at #{storename} for #{item_price}"
         end
        end
      end
    end
  end
  class Acme
    include Capybara::DSL
    def get_results(store,pricelist)

      visit(store)
      page.find(:xpath,"//a[@id = 'navigation-categories']").hover
      page.find(:link,"Meat & Seafood").click

=begin
Next steps:
	1. get max number of pages
	2. go to each page and search for keywords, adding hits to array
	3. return array
=end

      sleep 3

    end
    
  end
  class ShopRite
  end 
  class FreshGrocer
  end
end

shop = Shopper::APS.new
shop.get_results(pathmark,pathmark_prices)
shop.get_results(superfresh,superfresh_prices)
shop = Shopper::Acme.new
shop.get_results(acme,acme_prices)
