# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "prism-residential-service-client"
  s.version = "0.3.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andy Vanasse"]
  s.date = "2013-05-14"
  s.description = "An ActiveRecord-like interface for accessing the Resident Services API."
  s.email = "andyvanasse@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".ruby-gemset",
    ".ruby-version",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "config/service.yml.example",
    "lib/prism-residential-service-client.rb",
    "lib/prism-residential-service-client/anniversary.rb",
    "lib/prism-residential-service-client/anniversary_persistence.rb",
    "lib/prism-residential-service-client/config.rb",
    "lib/prism-residential-service-client/location.rb",
    "lib/prism-residential-service-client/location_persistence.rb",
    "lib/prism-residential-service-client/meal.rb",
    "lib/prism-residential-service-client/meal_persistence.rb",
    "lib/prism-residential-service-client/meal_type.rb",
    "lib/prism-residential-service-client/meal_type_course.rb",
    "lib/prism-residential-service-client/meal_type_course_persistence.rb",
    "lib/prism-residential-service-client/meal_type_persistence.rb",
    "lib/prism-residential-service-client/office_hour.rb",
    "lib/prism-residential-service-client/office_hour_persistence.rb",
    "lib/prism-residential-service-client/resident.rb",
    "lib/prism-residential-service-client/resident_persistence.rb",
    "lib/prism-residential-service-client/service_offering.rb",
    "lib/prism-residential-service-client/service_offering_persistence.rb",
    "lib/prism-residential-service-client/service_time.rb",
    "lib/prism-residential-service-client/service_time_persistence.rb",
    "lib/prism-residential-service-client/staff_member.rb",
    "lib/prism-residential-service-client/staff_member_persistence.rb",
    "lib/prism-residential-service-client/staff_position.rb",
    "lib/prism-residential-service-client/staff_position_persistence.rb",
    "lib/prism-residential-service-client/transportation_schedule.rb",
    "lib/prism-residential-service-client/transportation_schedule_persistence.rb",
    "lib/support/remote_record.rb",
    "lib/support/serializers.rb",
    "lib/support/validation.rb",
    "prism-residential-service-client.gemspec",
    "spec/location_spec.rb",
    "spec/meal_spec.rb",
    "spec/meal_type_course_spec.rb",
    "spec/meal_type_spec.rb",
    "spec/office_hour_spec.rb",
    "spec/resident_spec.rb",
    "spec/service_offering_spec.rb",
    "spec/service_time_spec.rb",
    "spec/spec_helper.rb",
    "spec/staff_member_spec.rb",
    "spec/staff_position_spec.rb",
    "spec/transportation_schedule_spec.rb"
  ]
  s.homepage = "http://github.com/andy.vanasse@prismcontent.com/prism-residential-service-client"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Client for the Prism Residential Service"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.6.2"])
      s.add_runtime_dependency(%q<activesupport>, ["> 2.3.5"])
      s.add_runtime_dependency(%q<json>, ["~> 1.7.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3.1"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<faker>, [">= 0"])
    else
      s.add_dependency(%q<typhoeus>, ["~> 0.6.2"])
      s.add_dependency(%q<activesupport>, ["> 2.3.5"])
      s.add_dependency(%q<json>, ["~> 1.7.0"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.3.1"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<faker>, [">= 0"])
    end
  else
    s.add_dependency(%q<typhoeus>, ["~> 0.6.2"])
    s.add_dependency(%q<activesupport>, ["> 2.3.5"])
    s.add_dependency(%q<json>, ["~> 1.7.0"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.3.1"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<faker>, [">= 0"])
  end
end

