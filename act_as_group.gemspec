lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'act_as_group/version'

Gem::Specification.new do |s|
  s.name        = 'act_as_group'
  s.version     = ActAsGroup::VERSION
  s.date        = '2018-06-28'
  s.summary     = ''
  s.description = ''
  s.authors     = ['F. Padillo']
  s.email       = 'fpadillo@nosolosoftware.es'
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.homepage    = 'http://rubygems.org/gems/act_as_group'
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 5.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mongoid'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'delayed_job_mongoid'
  s.add_development_dependency 'sidekiq'
end
