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
    # Non-cannonical
    DP: :f  # (From SAM)
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
end
