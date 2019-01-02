require 'rake'

Gem::Specification.new do |s|
  s.name          = 'aws-sdk-utils'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w(cfndsl_converge yaml_get cfndsl_chain_converge cfn_converge cfn_chain_converge)
  s.authors       = %w(someguy)
  s.summary       = 'aws-sdk-utils'
  s.description   = 'Low level utilities for dealing with AWS SDK'
  s.files         = FileList[ 'lib/**/*.rb' ]

  s.require_paths << 'lib'

  s.homepage      = 'https://github.com/stelligent/aws-sdk-utils'
  s.required_ruby_version = '>= 2.1.0'

  s.add_runtime_dependency('aws-sdk', '>= 2.6.14')
  s.add_runtime_dependency('cfndsl', '>= 0.11.11')
  s.add_runtime_dependency('trollop', '>= 2.1.2')
end
