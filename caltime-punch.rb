#!/usr/bin/env ruby

require 'mechanize'
require 'highline/import'

agent = Mechanize.new
agent.follow_meta_refresh = true
caltime_timestamp_url = "https://caltimeprod.berkeley.edu/wfc/applications/wtk/html/ess/timestamp-record.jsp"
caltime_base_url = "https://caltimeprod.berkeley.edu/"
username = ask("Username:") 
password = ask("Password:") { |q| q.echo = false }

cas_page = agent.get(caltime_base_url)
  
login_result_page = cas_page.form_with(:id => "loginForm") do |form|
  form.field_with(:id => 'username').value = username
  form.field_with(:id => 'password').value = password
end.submit

login_result_page.form_with(:action => "https://caltimeprod.berkeley.edu/wfc/logonESS_SSO").submit

# Now post to the page that records a timestamp
agent.post(caltime_timestamp_url)
