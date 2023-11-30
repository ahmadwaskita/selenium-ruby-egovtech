require 'selenium-webdriver'
require 'yaml'
require 'fileutils'
require 'json-schema'
require 'date'
require 'rest-client'
require 'json'
require 'rspec/expectations'

year_month_folder = Time.now.strftime('%Y_%m')
day_folder = Time.now.strftime('%Y_%m_%d')
results_file_path = File.expand_path("./test_results/#{year_month_folder}/#{day_folder}")

FileUtils.mkdir_p(results_file_path)

Before do |scenario|
 puts scenario.name
 $browser = Selenium::WebDriver.for :chrome
 $wait = Selenium::WebDriver::Wait.new(timeout: 15)
end

After do |scenario|
  $browser.close
end
