$:.push File.expand_path("../lib", __FILE__)
require 'dj_mon/version'

Gem::Specification.new do |s|
  s.name            = "dj_mon"
  s.version = DjMon::VERSION.dup
  s.files = Dir["{app,lib,config,vendor}/**/*"] + ["Gemfile"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "haml", ">= 3.1"
  s.add_dependency "bootstrap-will_paginate"

  s.add_development_dependency 'delayed_job_active_record'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'shoulda'

end
