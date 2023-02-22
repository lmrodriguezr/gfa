$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'gfa/version'
Gem::Specification.new do |s|
  s.name        = 'gfa'
  s.version     = GFA::VERSION
  s.summary     = 'Graphical Fragment Assembly (GFA) for Ruby'
  s.description = 'GFA is a graph representation of fragment assemblies'

  s.files = Dir[
    'lib/**/*.rb', 'test/**/*.rb',
    'Gemfile', 'Rakefile', 'README.md', 'LICENSE'
  ]

  # Dependencies
  s.add_dependency 'rgl', '~> 0.5'

  # Docs + tests
  s.has_rdoc = true
  s.extra_rdoc_files << 'README.md'
  s.rdoc_options = %w(lib README.md --main README.md)
  s.rdoc_options << '--title' << s.summary
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'

  # Metadata
  s.authors  = ['Luis M. Rodriguez-R']
  s.email    = 'lmrodriguezr@gmail.com'
  s.homepage = 'https://github.com/lmrodriguezr/gfa'
end
