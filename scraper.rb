#!/usr/bin/env ruby

require 'capybara'
require 'capybara/poltergeist'
require 'csv'

include Capybara::DSL
Capybara.default_driver = :poltergeist

doctors = []

CSV.foreach("./data/zipcodes.csv", headers: false) do |row|
  # BCBS Only Supports Providers in CA without selecting a plan
  next unless row[3] == "CA"
  
  zipcode = row[0].gsub(/"/, '')
  puts "Processing Zip Code: #{zipcode}"

  begin
  
    visit "https://www.blueshieldca.com/fap/app/search.html"

    fill_in "location", with: zipcode

    find("#findNowButton").click

    find("#agreedCheckbox").click

    find("#continueButtonImg").click

    sleep 10 # TODO: Continue after page loads

    20.times do
      all(".accAddSection").each do |doctor|
        name = doctor.find("span.docName").text
        specialization = doctor.find(".docSpecialization").text
        address = doctor.find(".docAddress").text
        phone = doctor.find(".docPhoneNumber").text

        doctors << {
          name:   name,
          specialization: specialization,
          address: address,
          phone: phone
        }
      end

      puts doctors.to_json

      page.find("#nextpage").click
      sleep 5
    end
  rescue Exception => e
    puts "Error Scraping Zip Code: #{zipcode}"
    puts e
  end
end
