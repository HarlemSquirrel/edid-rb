# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'edid-rb'
  s.version     = '0.0.1'
  s.date        = '2019-02-01'
  s.summary     = 'A Ruby library for reading Extended Display Identification Data'
  s.description = 'A Ruby library for reading EDID'
  s.authors     = ['Kevin McCormack']
  s.email       = 'harlemsquirrel@gmail.com'
  s.files       = Dir['config/*', 'lib/**/*', 'README.md']
  s.homepage    = 'https://github.com/HarlemSquirrel/edid-rb'
  s.license     = 'MIT'

  s.add_runtime_dependency 'bindata'
end
