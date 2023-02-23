class GFA::Record::Header < GFA::Record
  CODE = :H
  REQ_FIELDS = []
  OPT_FIELDS = {
    VN: :Z # Version number
  }

  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }
   
  def initialize(*opt_fields)
    @fields = {}
    opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
  end
end
