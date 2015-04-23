#!/usr/bin/env ruby

require 'mechanize'
require 'highline/import'

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
agent.post(caltime_timestamp_url)
