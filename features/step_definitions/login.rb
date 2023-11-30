require_relative "../../page_functionality/login_functionality.rb"

Given (/^I am on the SauceDemo Log In page$/) do
  $browser.get("https://www.saucedemo.com")
end

When (/^I enter the correct log in info and click Log In$/) do
  login = Login.new
  login.login_user("standard_user")
end

Then (/^I should be logged in and be directed to the home page$/) do
  expect($browser.current_url).to eql("https://www.saucedemo.com/inventory.html")
end


When (/^I enter an incorrect username$/) do
  login = Login.new
  login.login_user("not_a_user")
end

Then (/^I will get the Epic sadface error$/) do
  expect($browser.find_element(:tag_name, "h3").text.include?("Username and password do not match")).to eql true
end


When (/^I enter an incorrect password$/) do
  login = Login.new
  login.login_user("standard_user", "fake_password")
end

Then (/^I will get an error$/) do
  expect($browser.find_element(:tag_name, "h3").text.include?("Username and password do not match")).to eql true
end
