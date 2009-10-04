# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{watertower}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Gironda"]
  s.date = %q{2009-10-03}
  s.default_executable = %q{watertower}
  s.description = %q{Ruby and XUL based web application server framework.}
  s.email = %q{contact@gironda.org}
  s.executables = ["watertower"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitattributes",
     "README",
     "Rakefile",
     "VERSION",
     "xulapp/application.ini",
     "xulapp/chrome/chrome.manifest",
     "xulapp/chrome/content/data/motd.txt",
     "xulapp/defaults/preferences/prefs.js"
  ]
  s.homepage = %q{http://github.com/gabrielg/watertower}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Ruby and XUL based web application server framework.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
