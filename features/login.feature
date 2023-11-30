Feature: Log in to SauceDemo test page.
	As a Standard User
  I want to Log In to the website
  So that I can view the store items

Scenario: Log in to SauceDemo Website
	Given I am on the SauceDemo Log In page
	When I enter the correct log in info and click Log In
	Then I should be logged in and be directed to the home page

Scenario: Incorrect username when attempting to log in
	Given I am on the SauceDemo Log In page
	When I enter an incorrect username
	Then I will get the Epic sadface error

Scenario: Incorrect password when attempting to log in
	Given I am on the SauceDemo Log In page
	When I enter an incorrect password
	Then I will get an error
