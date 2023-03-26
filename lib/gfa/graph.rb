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

  ##
  # Extracts the subset of records associated to +segments+, which is an Array
  # with values of any class in: Integer (segment index),
  # String or GFA::Field::String (segment names), or GFA::Record::Segment.
  #
  # +degree+ indicates the maximum degree of separation between the original
  # segment set and any additional segments. Use 0 to include only the segments
  # in the set. Use 1 to include those, the records linking to them, and the
  # additional segments linked by those records. Use any integer greater than 1
  # to prompt additional rounds of greedy graph expansion.
  #
  # If +headers+, it includes all the original headers. Otherwise it only
  # only includes the version header (might be inferred).
  #
  # All comments are ignored even if originally parsed. Walks are currently
  # ignored too. If the current GFA object doesn't have an index, it builds one
  # and forces +index: true+. The output object inherits all options.
  def subgraph(segments, degree: 1, headers: true)
    # Prepare objects
    unless opts[:index]
      opts[:index] = true
      rebuild_index!
    end
    gfa = GFA.new(opts)
    segments =
      segments.map do |i|
        i.is_a?(GFA::Record::Segment) ? i :
          segment(i) or raise "Cannot find segment: #{i}"
      end

    # Headers
    if headers
      self.headers.set.each { |record| gfa << record }
    else
      gfa << GFA::Record::Header.new("VN:Z:#{gfa_version}")
    end

    # Original segments
    segments.each { |segment| gfa << segment }

    # Expand graph
    linking, edges = linking_records(gfa.segments, degree: degree)
    linking += internally_linking_records(segments, edges)
    linking.each { |record| gfa << record }

    # Return
    gfa
  end

  ##
  # Finds all the records linking to any segments in +segments+, a
  # GFA::RecordSet::SegmentSet object, and expands to links with up to
  # +degree+ degrees of separation
  #
  # It only evaluates the edges given in the +edges+ Array of GFA::Record
  # values. If +edges+ is +nil+, it uses the full set of edges in the gfa.
  # Edge GFA::Record objects can be of type Link, Containment, Jump, or Path
  #
  # If +_ignore+ is passed, it ignores this number of segments at the beginning
  # of the +segments+ set (assumes they have already been evaluated). This is
  # only used for internal heuristics
  #
  # Returns an Array of with two elements:
  # 0. An array of GFA::Record objects with all the identified linking records
  # 1. An array of GFA::Record objects with all edges that were not identified
  #
  # IMPORTANT NOTE 1: The object +segments+ will be modified to include all
  # linked segments. If you don't want this behaviour, please make sure to pass
  # a duplicate of the object instead.
  #
  # IMPORTANT NOTE 2: The list of linking records may not comprehensively
  # include all records linking the identified expanded segment set. To ensure
  # a consistent set is identified, use:
  # linking, edges = gfa.linking_records(segments)
  # linking += gfa.internally_linking_records(segments, edges)
  # 
  def linking_records(segments, degree: 1, edges: nil, _ignore: 0)
    unless segments.is_a? GFA::RecordSet::SegmentSet
      raise "Unrecognised class: #{segments.class}"
    end

    # Gather edges to evaluate
    edges ||= all_edges
    return [[], edges] if degree <= 0

    # Links, Containments, Jumps (from, to) and Paths (segment_names)
    linking = []
    eval_set = _ignore == 0 ? segments.set : segments.set[_ignore..]
    edges.delete_if do |edge|
      if eval_set.any? { |segment| edge.include? segment }
        linking << edge
        true  # Remove from the edge set to speed up future recursions
      else
        false # Keep it, possibly linking future recursions 
      end
    end

    # Recurse and return
    if degree >= 1
      pre = segments.size

      # Add additional linked segments
      linking.each do |record|
        record.segments(self).each do |other_seg|
          segments << other_seg unless segments[other_seg.name]
        end
      end

      # Recurse only if new segments were discovered
      if segments.size > pre
        $stderr.puts "- Recursion [#{degree}]: " \
                     "#{pre} -> #{segments.size}\t(#{edges.size})"
        linking +=
          linking_records(
            segments,
            degree: degree - 1, edges: edges, _ignore: pre
          )[0]
      end
    end
    [linking, edges]
  end

  def internally_linking_records(segments, edges)
    $stderr.puts '- Gathering internally linking records'
    segments = Hash[segments.set.map { |i| [i.name.value, true]}]
    edges.select { |record| record.segment_names_a.all? { |s| segments[s] } }
  end

  ##
  # Returns an array of GFA::Record objects including all possible edges
  # from the GFA. I.e., all links, jumps, containments, and paths.
  def all_edges
    edge_t = %i[Link Jump Containment Path]
    edges = edge_t.flat_map { |t| records[t].set } if edges.nil?
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

    def rgl_implicit_adjacent_iterator(x, b, opts)
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
