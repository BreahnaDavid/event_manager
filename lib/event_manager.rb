require "csv"
require 'erb'
require 'sunlight/congress'

FILE_NAME = "event_attendees.csv".freeze
TEMPLATE_NAME = "form_letter.erb".freeze

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  unless Dir.exists? "output"
    Dir.mkdir("output")
  end

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end

template_letter = File.read(TEMPLATE_NAME)
erb_template = ERB.new(template_letter)

rows = CSV.open(FILE_NAME, headers: true, header_converters: :symbol)

rows.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end
