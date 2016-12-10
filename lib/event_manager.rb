require "csv"
require 'sunlight/congress'

FILE_NAME = "event_attendees.csv".freeze
TEMPLATE_NAME = "form_letter.html".freeze

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)

  legislator_names = legislators.map do |legislator|
    "#{legislator.first_name} #{legislator.last_name}"
  end

  legislator_names.join(", ")
end

template_letter = File.read(TEMPLATE_NAME)

rows = CSV.open(FILE_NAME, headers: true, header_converters: :symbol)

rows.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  personal_letter = template_letter.gsub('FIRST_NAME', name)
  template_letter.gsub('LEGISLATORS', legislators)

  puts "#{name} #{zipcode} #{legislators}"
end
