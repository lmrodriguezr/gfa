class GFA::Record::Walk < GFA::Record
  CODE = :W
  REQ_FIELDS = %i[sample_id hap_index seq_id seq_start seq_end walk]
  OPT_FIELDS = {}

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end

  def initialize(sample_id, hap_index, seq_id, seq_start, seq_end, walk, *opt_fields)
    @fields = {}
    add_field(2, :Z, sample_id, /[!-)+-<>-~][!-~]*/)
    add_field(3, :i, hap_index, /[0-9]+/)
    add_field(4, :Z, seq_id,    /[!-)+-<>-~][!-~]*/)
    add_field(5, :i, seq_start, /\*|[0-9]+/)
    add_field(6, :i, seq_end,   /\*|[0-9]+/)
    add_field(7, :Z, walk,      /([><][!-;=?-~]+)+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
