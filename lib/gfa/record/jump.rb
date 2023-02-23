class GFA::Record::Jump < GFA::Record
  CODE = :J
  REQ_FIELDS = %i[from from_orient to to_orient distance]
  OPT_FIELDS = {
    SC: :i  # 1 indicates indirect shortcut connections. Only 0/1 allowed.
  }

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }

  def initialize(from, from_orient, to, to_orient, distance, *opt_fields)
    @fields = {}
    add_field(2, :Z, from,        /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, from_orient, /[+-]/)
    add_field(4, :Z, to,          /[!-)+-<>-~][!-~]*/)
    add_field(5, :Z, to_orient,   /[+-]/)
    add_field(6, :Z, distance,    /\*|[-+]?[0-9]+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end

  def from?(segment, orient = nil)
    links_from_to?(segment, orient, true)
  end

  def to?(segment, orient = nil)
    links_from_to?(segment, orient, false)
  end

  private

    def links_from_to?(segment, orient, from)
      segment = segment_name(segment)
      orient  = orient.value if orient.is_a? GFA::Field
      base_k  = from ? 2 : 4
      segment==fields[base_k].value &&
        (orient.nil? || orient==fields[base_k + 1].value)
    end

    def segment_name(segment)
      segment.is_a?(GFA::Record::Segment) ? segment.name.value :
        segment.is_a?(GFA::Field) ? segment.value : segment
    end
end
