
class GFA
  ##
  # Find all independent modules by greedily crawling the linking entries for
  # each segment, and returns an Array of GFA objects containing each individual
  # module. If +recalculate+ is false, it trusts the current calculated
  # matrix unless none exists
  def split_modules(recalculate = true)
    recalculate_matrix if recalculate || @matrix.nil?
    missing_segments = (0 .. @matrix_segment_names.size - 1).to_a
    modules = []
    until missing_segments.empty?
      mod = matrix_find_module(missing_segments[0])
      mod.segments.set.map(&:name).map(&:value).each do |name|
        missing_segments.delete(@matrix_segment_names.index(name))
      end
      modules << mod
    end
    modules
  end

  ##
  # Finds the entire module containing the segment with index +segment_index+
  # in the matrix (requires calling +recalculate_matrix+ first!). Returns the
  # module as a new GFA
  def matrix_find_module(segment_index)
    # Initialize
    segs = [segment_index]
    edges = []
    new_segs = true

    # Iterate until no new segments are found
    while new_segs
      new_segs = false
      segs.each do |seg|
        @matrix.size.times do |k|
          next if seg == k
          v = @matrix[[seg, k].max][[seg, k].min]
          next if v.empty?
          edges += v
          unless segs.include?(k)
            new_segs = true
            segs << k
          end
        end
      end
    end

    # Save as GFA and return
    o = GFA.new
    segs.each { |k| o << segments[k] }
    edges.uniq.each { |k| o << @matrix_edges[k] }
    o
  end

  ##
  # Calculates a matrix where all links between segments are represented by the
  # following variables:
  # 
  # +@matrix_segment_names+ includes the names of all segments (as String) with
  # the order indicating the segment index in the matrix
  #
  # +@matrix+ is an Array of Arrays of Arrays, where the first index indicates
  # the row index segment, the second index indicates the column index segment,
  # and the third index indicates each of the links between those two. Note that
  # matrix only stores the lower triangle, so the row index must be stictly less
  # than the column index. For example, +@matrix[3][1]+ returns an Array of all
  # index links between the segment with index 3 and the segment with index 1:
  # ```
  # [
  #   [             ], # Row 0 is always empty
  #   [[]           ], # Row 1 stores connections to column 0
  #   [[], []       ], # Row 2 stores connections to columns 0 and 1
  #   [[], [], []   ], # Row 3 stores connections to columns 0, 1, and 2
  #   ...              # &c
  # ]
  # ```
  #
  # +@matrix_edges+ is an Array of GFA::Record objects representing all edges in
  # the GFA. The order indicates the index used by the values of +@matrix+
  def recalculate_matrix
    @matrix_segment_names = segments.set.map(&:name).map(&:value)
    @matrix = @matrix_segment_names.size.times.map { |i| Array.new(i) { [] } }
    @matrix_edges = all_edges
    @matrix_edges.each_with_index do |edge, k|
      names = edge.segments(self).map(&:name).map(&:value)
      indices = names.map { |i| @matrix_segment_names.index(i) }
      indices.each do |a|
        indices.each do |b|
          break if a == b
          @matrix[[a, b].max][[a, b].min] << k
        end
      end
    end
  end
end
