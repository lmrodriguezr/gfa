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
  # Calculate and store internally a matrix representing all edges.
  def calculate_edge_matrix!
    $stderr.puts '- Building edge matrix'
    @edge_matrix = GFA::Matrix.new(segments.size, segments.size)
    self.class.advance_bar(all_edges.size)
    all_edges.each do |edge|
      self.class.advance
      idx = edge.segments(self).map { |i| segments.position(i) }
      idx.each do |i|
        idx.each do |j|
          @edge_matrix[i, j] = true unless i == j
        end
      end
    end
    @edge_matrix
  end

  ##
  # Returns the matrix representing all edges
  def edge_matrix
    @edge_matrix or calculate_edge_matrix!
  end

  ##
  # Extracts the subset of records associated to +segments+, which is an Array
  # with values of any class in:
  # - Integer: segment index,
  # - String or GFA::Field::String: segment names, or
  # - GFA::Record::Segment: the actual segments themselves
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
  # +threads+ indicates the number of threads to use in the processing of this
  # operation, currently only affecting expansion rounds.
  #
  # All comments are ignored even if originally parsed. Walks are currently
  # ignored too. If the current GFA object doesn't have an index, it builds one
  # and forces +index: true+. The output object inherits all options.
  def subgraph(segments, degree: 1, headers: true, threads: 2)
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
    linking = linking_records(gfa.segments, degree: degree, threads: threads)
    linking.each { |record| gfa << record }

    # Return
    gfa
  end

  ##
  # Finds all the records linking to any segments in +segments+, a
  # GFA::RecordSet::SegmentSet object, and expands to links with up to
  # +degree+ degrees of separation. This operation uses +threads+ Threads
  # (with shared RAM)
  #
  # Returns an array of GFA::Record objects with all the identified linking
  # records (edges). Edge GFA::Record objects can be of type: Link, Containment,
  # Jump, or Path
  #
  # IMPORTANT NOTE: The object +segments+ will be modified to include all
  # linked segments. If you don't want this behaviour, please make sure to pass
  # a duplicate of the object instead
  def linking_records(segments, degree: 1, threads: 2)
    unless segments.is_a? GFA::RecordSet::SegmentSet
      raise "Unrecognised class: #{segments.class}"
    end

    edge_matrix unless degree == 0 # Just to trigger matrix calculation
    degree.times do |round|
      $stderr.puts "- Expansion round #{round + 1}"
      self.class.advance_bar(segments.size + 1)
      pre_expansion = segments.size

      # Launch children processes
      io  = []
      pid = []
      threads.times do |t|
        io[t] = IO.pipe
        pid << fork do
          new_segments = Set.new
          segments.set.each_with_index do |segment, k|
            self.class.advance if t == 0
            next unless (k % threads) == t
            idx = self.segments.position(segment)
            edge_matrix[nil, idx].each_with_index do |edge, target_k|
              new_segments << target_k if edge
            end
          end
          Marshal.dump(new_segments, io[t][1])
          self.class.advance if t == 0
          exit!(0)
        end
        io[t][1].close
      end

      # Collect and merge results
      new_segments = Set.new
      io.each_with_index do |pipe, k|
        result = pipe[0].read
        Process.wait(pid[k])
        self.class.advance_bar(io.size) if k == 0
        raise "Child process failed: #{k}" if result.empty?
        new_segments += Marshal.load(result)
        pipe[0].close
        self.class.advance
      end
      new_segments = new_segments.map { |i| self.segments[i] }
      new_segments.each { |i| segments << i unless segments[i.name] }
      new = segments.size - pre_expansion
      $stderr.puts "  #{new} segments found, total: #{segments.size}"
      break if new == 0
    end

    internally_linking_records(segments, all_edges)
  end

  def internally_linking_records(segments, edges)
    unless segments.is_a? GFA::RecordSet::SegmentSet
      raise "Unrecognised class: #{segments.class}"
    end

    $stderr.puts '- Gathering internally linking records'
    s_names = Hash[segments.set.map { |i| [i.name.value, true]}]
    self.class.advance_bar(edges.size)
    edges.select do |record|
      self.class.advance
      record.segment_names_a.all? { |s| s_names[s] }
    end
  end

  ##
  # Returns an array of GFA::Record objects including all possible edges
  # from the GFA. I.e., all links, jumps, containments, and paths.
  def all_edges
    edge_t = %i[Link Jump Containment Path]
    @edges ||= edge_t.flat_map { |t| records[t].set }
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
