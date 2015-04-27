Gem::Specification.new do |s|
  s.name        = 'caltime'
  s.version     = '0.0.1'
  s.date        = '2015-04-24'
  s.summary     = "CalTime CLI tool"
  s.description = "Uses web scraping to punch in, punch out, report status, and display a time card in a shell"
  s.authors     = ["Nicholas Herson"]
  s.email       = 'nicholas.herson@gmail.com'
  s.files       = ["lib/caltime.rb"]
  s.license       = 'MIT'
  s.add_runtime_dependency 'mechanize'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency 'terminal-table'
  s.add_development_dependency 'debugger'
  s.executables << 'caltime'
end
