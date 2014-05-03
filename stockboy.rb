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

module Shopper
  class SuperFresh
    include Capybara::DSL
    def get_results
      visit('http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf')
      sleep 1
      page.driver.browser.switch_to.frame(0)
      sleep 2
      page.first(:link,'Text Only').click
      sleep 1
			#add each loop for categories in arg array
      page.first(:link,'Meat').click
			sleep 2
    end
  end
end

shop = Shopper::SuperFresh.new
shop.get_results
exit

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


# Dead ended with mechanize, which doesn't seem to play well with JavaScript
##### MECHANIZE ###########
#agent = Mechanize.new
#page = agent.get('http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf')
#iframe_page = agent.click page.iframes.first
#test = agent.click(iframe_page.link_with(:text => /Text Only/))
#iframe_page.link_with(:text => /Text Only/) do |l|
#  puts l.text
#  Mechanize::Page::Link.new(l, agent, iframe_page).click
#end
#l = iframe_page.search ".//a
#end 
