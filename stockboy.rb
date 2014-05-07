#!/usr/bin/env ruby

# Working on a script that crawls supermarket pages and comparison shops for me.

#require 'mechanize'
#require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'

require 'capybara/dsl'
require 'capybara-webkit'
Capybara.run_server = false
#Capybara.current_driver = :webkit
Capybara.current_driver = :selenium
Capybara.app_host = "http://www.google.com"

pathmark = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
superfresh = 'http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf'

module Shopper
  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    def get_results(store)
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
        puts page.find('script', :text => /itemPrice#{meat}/).text.match
        #find isn't picking anything up...why not?
      end
    end
  end
  class Acme
  end
  class ShopRite
  end 
end

shop = Shopper::APS.new
shop.get_results('http://pathmark.apsupermarket.com/view-circular?storenum=532#ad')
#shop.get_results('http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf')

=begin
playing with poltergeist
Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
    options = {
        :js_errors => true,
        :timeout => 120,
        :debug => false,
        :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
        :inspector => true,
    }
    Capybara::Poltergeist::Driver.new(app, options)
end

visit('http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf')
=end
