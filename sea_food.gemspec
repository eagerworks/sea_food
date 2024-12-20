lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sea_food/version'

# :rubocop:disable
Gem::Specification.new do |spec|
  spec.name          = 'sea_food'
  spec.version       = SeaFood::VERSION
  spec.authors       = ['Federico Aldunate']
  spec.email         = ['federico.aldunatec@gmail.com']

  spec.summary       = 'A Ruby gem for seamlessly integrating form and service object patterns.'
  spec.homepage      = 'https://github.com/eagerworks/sea_food'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/eagerworks/sea_food/'
    spec.metadata['changelog_uri'] = 'https://github.com/eagerworks/sea_food/releases'
    spec.metadata['bug_tracker_uri'] = 'https://github.com/eagerworks/sea_food/issues'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 5.2'
  spec.add_dependency 'activesupport', '>= 5.2'

  spec.add_development_dependency 'activerecord', '>= 5.2'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 2.2.0'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'sqlite3', '~> 1.5.0'
end
