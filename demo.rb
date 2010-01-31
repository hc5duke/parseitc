require 'rubygems'
require 'lib/parseitc'
include ParseITC

begin
  report = TrasactionParser.new('demo1.txt')
  report.add_file('demo2.txt')
  by_country = report.numbers_by_country
  by_country.sort.each {|k, v| puts "#{k}: #{v}"}
  by_date = report.numbers_by_date
  by_date.sort.each {|k, v| puts "#{k}: #{v}"}
  by_royalty_currency = report.numbers_by_price_tier
  by_royalty_currency.sort.each {|k, v| puts "#{k}: #{v}"}
rescue Errno::ENOENT 
  puts "The data file you specified was not found"
rescue Errno::EACCES 
  puts "The data file you specified is not readable"
end
