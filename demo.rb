require 'rubygems'
require 'lib/parseitc'
include ParseITC

begin
  report = Parser.new('demo1.txt')
  report.add_file('demo2.txt')

  puts '=' * 20
  puts "Sales in top 10 countries"
  report.count_by_country.sort_by{|k,v| v}.reverse[0..9].each do |k, v|
    puts "  #{k}: #{v}"
  end

  puts
  puts '=' * 20
  puts "Sales volume per day"
  report.count_by_date.sort.each do |k, v|
    puts "  #{k}: #{v}"
  end

  puts
  puts '=' * 20
  puts "Sales by price and date"
  total = 0
  report.split_by_date.sort.each do |k1, v1|
    puts "  #{k1}"
    v1.count_by_price_tier.sort.each do |k2, v2|
      dollars = ApplePricing[:usd][k2]
      puts "    $ #{dollars.to_f}: #{v2}"
      total += dollars.to_f * v2
    end
  end
  puts "Revenue: $#{total/7*10} "
  puts "Profit: $#{total} "

rescue Errno::ENOENT 
  puts "The data file you specified was not found"
rescue Errno::EACCES 
  puts "The data file you specified is not readable"
end
