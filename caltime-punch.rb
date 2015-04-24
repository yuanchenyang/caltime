#!/usr/bin/env ruby

require 'mechanize'
require 'highline/import'
require 'nokogiri'
require 'terminal-table'
require 'colorize'

if ["help", "-h", "--help"].include?(ARGV[0])
  puts "
    USAGE: caltime-punch.rb
    No arguments needed, the script will prompt for CalNet ID and passphrase

    Source: https://github.com/nherson/caltime-punch
    "
  exit 1
end

# Initialize Mechanize agent and set config
agent = Mechanize.new
agent.follow_meta_refresh = true

caltime_timestamp_url = "https://caltimeprod.berkeley.edu/wfc/applications/wtk/html/ess/timestamp-record.jsp"
caltime_base_url = "https://caltimeprod.berkeley.edu/"
cal_sso_url = "https://caltimeprod.berkeley.edu/wfc/logonESS_SSO"

page = agent.get(caltime_base_url)
  
loop do

  page = page.form_with(:id => "loginForm") do |form|
    form.field_with(:id => 'username').value = ask("CalNet Username: ") 
    form.field_with(:id => 'password').value = ask("CalNet Password: ") { |q| q.echo = false }
  end.submit

  if page.uri.to_s =~ /auth\.berkeley\.edu/
    puts ""
    puts "Login incorrect, please try again."
  else
    break
  end

end

page.form_with(:action => cal_sso_url).submit

# Now post to the page that records a timestamp
page = agent.post(caltime_timestamp_url)
if page.code != 200
  puts "There was an issue recording your punch."
  exit 1
else
  puts "Punch successfully recorded."
end


# Fetch and render the user's timecard
page = agent.get("https://caltimeprod.berkeley.edu/wfc/applications/mss/managerlaunch.do")
page = page.link_with(:text => "My Timecard").click
html = Nokogiri::HTML(page.body)
table = html.css('table[class="Tabular Timecard"]')
rows = table.css('tbody tr')
red_line = "          ".on_red
table_data = []
total = 0
rows.each do |row|
  inpunch_el = row.css('td[class="InPunch"]')[0]
  outpunch_el = row.css('td[class="OutPunch"]')[0]
  date_el = row.css('td[class="Date"]')[0]
  amount_el = row.css('td[class="ShiftTotal"]')[0]
  inpunch = inpunch_el["title"] == "Missed In-Punch" ? red_line : inpunch_el.text.gsub(/[\n\t\r]/, "")
  outpunch = outpunch_el["title"] == "Missed Out-Punch" ? red_line : outpunch_el.text.gsub(/[\n\t\r]/, "")
  date = date_el.text
  amount = amount_el.text.gsub(/[\n\t\r]/, "")
  begin
    total += amount.to_f
  rescue
    total += 0
  end
  table_data << [date, inpunch, outpunch, amount]
end
pretty_table = Terminal::Table.new :rows => table_data, :headings => ['Date', 'Punch In', 'Punch Out', 'Hours']
pretty_table.add_separator
pretty_table.add_row ["","","Total", total]
pretty_table.style = {:width => 50}
pretty_table.columns[2][12] = "          ".on_red
puts pretty_table

# Tells you your status
today = Time.now.strftime("%a %-m/%-d")
table = html.css('table[class="Tabular Timecard"]')
rows = table.css('tbody tr')
latest_today_row = rows.select { |row| row.text =~ /#{today}/ }[-1]
# See if the column has any numbers as a way to check if its 'punched'
punched_in = latest_today_row.css('td[class="InPunch"]').text =~ /[0-9]:[0-9][0-9]/
punched_out = latest_today_row.css('td[class="OutPunch"]').text =~ /[0-9]:[0-9][0-9]/
if (punched_in and punched_out) or (!punched_in and !punched_out)
  puts "You ARE NOT currently punched in."
elsif punched_in
  puts "You ARE currently punched in."
else
  puts "I have no idea wtf is going on with your punches, figure it out manually."
end
