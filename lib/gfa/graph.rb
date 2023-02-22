require 'rgl/adjacency'
require 'rgl/implicit'

class GFA
   
  ##
  # Generates a RGL::ImplicitGraph object describing the links in the GFA.
  # The +opts+ argument is a hash with any of the following key-value pairs:
  #
  # * :orient => bool. If false, ignores strandness of the links. By default
  #   true.
  # * :directed => bool. If false, ignores direction of the links. By defaut
  #   the same value as :orient.
  def implicit_graph(opts = {})
    rgl_implicit_graph(opts)
  end

  ##
  # Generates a RGL::DirectedAdjacencyGraph or RGL::AdjacencyGraph object.
  # The +opts+ argument is a hash with the same supported key-value pairs as
  # in #implicit_graph.
  def adjacency_graph(opts = {})
    implicit_graph(opts).to_adjacency
  end
   
  private
   
    def segment_names_with_orient
      segments.flat_map do |s|
        %w[+ -].map { |orient| GFA::GraphVertex.idx(s, orient) }
      end.to_set
    end

    def segment_names
      segments.map do |s|
        GFA::GraphVertex.idx(s, nil)
      end.to_set
    end

    def rgl_implicit_graph(opts)
      opts = rgl_implicit_options(opts)
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |b|
          (opts[:orient] ? segment_names_with_orient :
                  segment_names).each(&b)
        end
        g.adjacent_iterator do |x, b|
          rgl_implicit_adjacent_iterator(x, b, opts)
        end
        g.directed = opts[:directed]
      end
    end

    def rgl_implicit_options(opts)
      opts[:orient] = true if opts[:orient].nil?
      opts[:directed] = opts[:orient] if opts[:directed].nil?
      opts
    end

    def rgl_implicit_adjacent_iterator(x,b,opts)
      links.each do |l|
        if l.from?(x.segment, x.orient)
          orient = opts[:orient] ? l.to_orient : nil
          b.call(GFA::GraphVertex.idx(l.to, orient))
        elsif opts[:orient] && l.to?(x.segment, orient_rc(x.orient))
          orient = orient_rc(l.from_orient.value)
          b.call(GFA::GraphVertex.idx(l.from, orient))
        end
      end
    end

    def orient_rc(o)
      o == '+' ? '-' : '+'
    end
end


class GFA::GraphVertex # :nodoc:
  # Class-level
  @@idx = {}
  def self.idx(segment, orient)
    n = GFA::GraphVertex.new(segment, orient)
    @@idx[n.to_s] ||= n
    @@idx[n.to_s]
  end

  # Instance-level
  attr :segment, :orient

  def initialize(segment, orient)
    @segment = segment.is_a?(GFA::Record::Segment) ? segment.name.value :
		segment.is_a?(GFA::Field) ? segment.value : segment
    @orient  = orient.is_a?(GFA::Field) ? orient.value : orient
  end

  def to_s
    "#{segment}#{orient}"
  end
end
