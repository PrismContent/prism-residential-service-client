# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "prism-residential-service-client"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andy Vanasse"]
  s.date = "2012-04-18"
  s.description = "TODO: longer description of your gem"
  s.email = "andyvanasse@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "config/service.yml",
    "lib/prism-residential-service-client.rb",
    "lib/prism-residential-service-client/config.rb",
    "lib/prism-residential-service-client/meal.rb",
    "lib/prism-residential-service-client/meal_persistence.rb",
    "lib/prism-residential-service-client/meal_type.rb",
    "lib/prism-residential-service-client/meal_type_course.rb",
    "lib/prism-residential-service-client/meal_type_course_persistence.rb",
    "lib/prism-residential-service-client/meal_type_persistence.rb",
    "prism-residential-service-client.gemspec",
    "spec/meal_spec.rb",
    "spec/meal_type_course_spec.rb",
    "spec/meal_type_spec.rb",
    "spec/prism-residential-service-client_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/andy.vanasse@prismcontent.com/prism-residential-service-client"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.17"
  s.summary = "Client for the Prism Residential Service"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.3.3"])
      s.add_runtime_dependency(%q<activesupport>, ["> 2.3.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1.3"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<typhoeus>, ["~> 0.3.3"])
      s.add_dependency(%q<activesupport>, ["> 2.3.0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.1.3"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<typhoeus>, ["~> 0.3.3"])
    s.add_dependency(%q<activesupport>, ["> 2.3.0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.1.3"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

