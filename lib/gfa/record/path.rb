class GFA::Record::Path < GFA::Record
  CODE = :P
  REQ_FIELDS = %i[path_name segment_names overlaps]
  OPT_FIELDS = {}

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end

  alias segment_name segment_names
  alias cigar overlaps

  def initialize(path_name, segment_names, overlaps, *opt_fields)
    @fields = {}
    add_field(2, :Z, path_name,     /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, segment_names, /[!-)+-<>-~][!-~]*/)
    add_field(4, :Z, overlaps,      /\*|([0-9]+[MIDNSHPX=]|[-+]?[0-9]+J|.)+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end

  ##
  # Array of segment names (without orientations) as strings
  def segment_names_a
    segment_names.value.split(/[,;]/).map { |i| i.gsub(/[+-]$/, '') }
  end

  ##
  # Extracts all linked segments from +gfa+ (which *must* be indexed)
  def segments(gfa)
    raise "Unindexed GFA" unless gfa.indexed?
    segment_names_a.map do |name|
      gfa.segments[name]
    end
  end

  ##
  # Includes a GFA::Record::Segment +segment+?
  def include?(segment)
    # unless segment.is_a? GFA::Record::Segment
    #   raise "Unrecognized class: #{segment.class}"
    # end

    segment_names_a.any? { |name| segment.name == name }
  end

  ##
  # Array of GFA::Field::String with the sequences from each segment featuring
  # the correct orientation from a +gfa+ (which *must* be indexed)
  #
  # TODO: Distinguish between a direct path (separated by comma) and a
  # jump (separated by semicolon). Jumps include a distance estimate
  # (column 6, optional) which could be used to add Ns between segment
  # sequences (from GFA 1.2)
  def segment_sequences(gfa)
    raise "Unindexed GFA" unless gfa.indexed?
    segment_names.value.split(/[,;]/).map do |i|
      orientation = i[-1]
      i[-1] = ''
      segment = gfa.segments[i]

      case orientation
        when '+' ; segment.sequence
        when '-' ; segment.rc
        else ; raise "Unknown orientation: #{orientation} (path: #{path_name})"
      end
    end
  end

  ##
  # Produce the contiguous path sequence based on the segment sequences and
  # orientations from a +gfa+ (which *must* be indexed)
  #
  # TODO: Estimate gaps (Ns) from Jump distances (see +segment_sequences+)
  #
  # TODO: Attempt reading CIGAR values from the path first, the corresponding
  # links next, and actually performing the pairwise overlap as last resort
  #
  # TODO: Support ambiguous IUPAC codes for overlap evaluation
  def sequence(gfa)
    segment_sequences(gfa).map(&:value)
      .inject('') { |a, b| a + after_overlap(a, b) }
  end

  private
    ##
    # Find the overlap between sequences +a+ and +b+ (Strings) and return
    # only the part of +b+ after the overlap. Assumes that +a+ starts
    # at the same point or before +b+. If no overlap is found, returns +b+
    # in its entirety.
    def after_overlap(a, b)
      (0 .. a.length - 1).each do |a_from|
        a_to = b.length + a_from > a.length ? a.length : b.length + a_from
        b_to = b.length + a_from > a.length ? a.length - a_from : b.length
        if a[a_from .. a_to - 1] == b[0 .. b_to - 1]
          return b[b_to .. b.length].to_s
        end
      end
      b
    end
end
