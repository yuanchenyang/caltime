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
  s.add_runtime_dependency 'mechanize', '~> 2.7'
  s.add_runtime_dependency 'highline', '~> 1.6'
  s.add_runtime_dependency 'colorize', '~> 0.7'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'terminal-table', '~> 1.4'
  s.add_development_dependency 'debugger', '~> 1.6'
  s.executables << 'caltime'
end
