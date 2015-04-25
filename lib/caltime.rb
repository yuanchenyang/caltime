require 'mechanize'
require 'highline/import'
require 'nokogiri'
require 'terminal-table'
require 'colorize'

class Caltime

  TIMESTAMP_URL = "https://caltimeprod.berkeley.edu/wfc/applications/wtk/html/ess/timestamp-record.jsp"
  BASE_URL = "https://caltimeprod.berkeley.edu/"
  SSO_URL = "https://caltimeprod.berkeley.edu/wfc/logonESS_SSO"

  def initialize
    @agent = Mechanize.new
    @agent.follow_meta_refresh = true
    @authed = false
  end

  def authenticate
    page = @agent.get(BASE_URL)
    loop do
      count = 0
      page = page.form_with(:id => "loginForm") do |form|
        form.field_with(:id => 'username').value = ask("CalNet Username: ") 
        form.field_with(:id => 'password').value = ask("CalNet Password: ") { |q| q.echo = false }
      end.submit
      # Did we get redirected back to the login page?
      if page.uri.to_s =~ /auth\.berkeley\.edu/
        # Bail after 3 failures
        count += 1
        raise SecurityError("Too many failed authentication attempts") unless count < 3
        puts "\nLogin incorrect, please try again."
      else
        break
      end
    end
    # Strange extra SSO submission step
    page.form_with(:action => SSO_URL).submit
    # Let other methods know we are now authenticated
    @authed = true
  end

  def punch
    authenticate unless @authed
    page = @agent.post(TIMESTAMP_URL)
    if page.code != 200
      # TODO: Raise some sort of custom error here
    end
  end

  # Returns a Terminal::Table object that can be pretty-printed and contains timecard data
  # TODO: Have this method return something less print-oriented and more data-oriented.
  #       Maybe something that can easily be converted to a terminal-table, idk
  #       For now, if called like CalTime.timecard raw: true, will return 2D array
  def timecard(options={})
    authenticate unless @authed
    rows = fetch_timecard_rows  
    table_data = []
    total = 0
    rows.each do |row|
      date, inpunch, outpunch, amount = timecard_row_to_array(row)
      begin
        total += amount.to_f
      rescue
        total += 0
      end
      table_data << [date, inpunch, outpunch, amount]
    end
    return table_data if options[:raw]
    pretty_table = Terminal::Table.new :rows => table_data, :headings => ['Date', 'Punch In', 'Punch Out', 'Hours']
    pretty_table.add_separator
    pretty_table.add_row ["","","Total", total]
    pretty_table.style = {:width => 50}
    pretty_table
  end

  def punched_in?
    today = Time.now.strftime("%a %-m/%-d")
    latest_today_row = fetch_timecard_rows.select { |row| row.text =~ /#{today}/ }[-1]
    punched_in = latest_today_row.css('td[class="InPunch"]').text =~ /[0-9]:[0-9][0-9]/
    punched_out = latest_today_row.css('td[class="OutPunch"]').text =~ /[0-9]:[0-9][0-9]/
    if (punched_in and punched_out) or (!punched_in and !punched_out)
      return false
    elsif punched_in
      return true
    else
      # TODO: Raise some kind of custom error instead
      return false
    end
  end

  def punched_out?
    return !punched_in?
  end

  private

  def fetch_timecard_rows
    page = @agent.get("https://caltimeprod.berkeley.edu/wfc/applications/mss/managerlaunch.do")
    page = page.link_with(:text => "My Timecard").click
    html = Nokogiri::HTML(page.body)
    table = html.css('table[class="Tabular Timecard"]')
    table.css('tbody tr')
  end

  def timecard_row_to_array(row)
    red_line = "          ".on_red
    inpunch_el = row.css('td[class="InPunch"]')[0]
    outpunch_el = row.css('td[class="OutPunch"]')[0]
    date_el = row.css('td[class="Date"]')[0]
    amount_el = row.css('td[class="ShiftTotal"]')[0]
    inpunch = inpunch_el["title"] == "Missed In-Punch" ? red_line : inpunch_el.text.gsub(/[\n\t\r]/, "")
    outpunch = outpunch_el["title"] == "Missed Out-Punch" ? red_line : outpunch_el.text.gsub(/[\n\t\r]/, "")
    date = date_el.text
    amount = amount_el.text.gsub(/[\n\t\r]/, "")
    [date, inpunch, outpunch, amount]
  end
end
