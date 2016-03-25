$:.unshift File.join(File.dirname(__FILE__), "lib")

require "gfa/version"
Gem::Specification.new do |s|
   s.name        = "gfa"
   s.version     = GFA::VERSION
   s.summary     = "Graphical Fragment Assembly (GFA) for Ruby"
   s.description = "GFA is a graph representation of fragment assemblies"

   # Docs + tests
   s.add_development_dependency "rake"
   s.add_development_dependency "test-unit"
   s.has_rdoc = true

   # Metadata
   s.authors  = ["Luis M. Rodriguez-R"]
   s.email    = "lmrodriguezr@gmail.com"
   s.homepage = "https://github.com/lmrodriguezr/gfa"
end
