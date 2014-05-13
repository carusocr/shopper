#!/usr/bin/env ruby

# Working on a script that crawls supermarket pages and comparison shops for me.

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

module Shopper
  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    def get_results(store,pricelist)
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
      num_rows = page.find('span', :text => /Showing items 1-/).text.match(/of (\d+)/).captures
      num_rows[0].to_i.times do |meat|
        item_name =  page.find(:xpath, "//div[@id = 'itemName#{meat}']").text
        item_price = page.find(:xpath, "//td[@id = 'itemPrice#{meat}']").text
        pricelist["#{item_name}"] = item_price
      end
    end
  end
  class Acme
  end
  class ShopRite
  end 
end

shop = Shopper::APS.new
shop.get_results(pathmark,pathmark_prices)
shop.get_results(superfresh,superfresh_prices)
