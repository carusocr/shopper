#!/usr/bin/env ruby

# Working on a script that crawls supermarket pages and comparison shops for me.

require 'mechanize'
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'

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

#agent.get('http://superfreshfood.inserts2online.com/customer_Frame.jsp?drpStoreID=747&showFlash=false').search("Store").each do |page|
#       puts page.content
#end
#doc = Nokogiri::HTML(open('http://www.thefreshgrocer.com/Shop/WeeklyAdTextOnly.aspx'))
#puts doc.content

#doc.search('Store').each do |link|
#       puts link.content
#end

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
