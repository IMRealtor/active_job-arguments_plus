# -*- encoding: utf-8 -*-

require_relative 'lib/active_job/arguments_plus/version'
require 'rake/file_list'

Gem::Specification.new do |gem|
  gem.name          = "active_job-arguments_plus"
  gem.version       = ::ActiveJob::ArgumentsPlus::VERSION
  gem.summary       = "ActiveJob Argument Serialization Extension"
  gem.description   = "."
  gem.license       = "MIT"
  gem.authors       = ["Piotr Banasik"]
  gem.email         = "piotr.banasik@gmail.com"
  gem.homepage      = "https://github.com/imrealtor/active_job-arguments_plus"
  gem.required_ruby_version = '~> 2.2'

  gem.files         = Rake::FileList['lib/**/*.rb']
  gem.executables   = Rake::FileList['bin/**/*']
  gem.test_files    = Rake::FileList['{test|spec|features}/**/*']
  gem.require_paths = ['lib']

  gem.add_dependency 'activejob', '~> 5.1'

  gem.add_development_dependency 'rake', '~> 12.3'
  gem.add_development_dependency 'bundler', '~> 1.16'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
