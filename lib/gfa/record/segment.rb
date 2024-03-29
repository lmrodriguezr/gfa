class GFA::Record::Segment < GFA::Record
  CODE = :S
  REQ_FIELDS = %i[name sequence]
  OPT_FIELDS = {
    LN: :i, # Segment length
    RC: :i, # Read count
    FC: :i, # Fragment count
    KC: :i, # k-mer count
    SH: :H, # SHA-256 checksum of the sequence
    UR: :Z, # URI or local file-system path of the sequence
    # Non-cannonical but uppercase (thus, reserved)
    DP: :f, # SAM
    SN: :Z, # rGFA: Name of stable sequence from which the segment is derived
    SO: :i, # rGFA: Offset on the stable sequence
    SR: :i  # rGFA: Rank. 0 if on a linear reference genome; >0 otherwise
  }

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }
   
  def initialize(name, sequence, *opt_fields)
    @fields = {}
    add_field(2, :Z, name,     /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, sequence, /\*|[A-Za-z=.]+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end

  ##
  # Returns the length of the sequence represented in this segment
  def length
    sequence.value.length
  end

  ##
  # Returns the reverse-complement of the sequence (as a Z field)
  def rc
    GFA::Field::String.new(
      sequence.value.upcase.reverse.tr('ACGTURYSWKMBDHVN', 'TGCAAYRSWMKVHDBN')
    )
  end
end
