class GFA::Record::Comment < GFA::Record
  CODE = :'#'
  REQ_FIELDS = %i[comment]
  OPT_FIELDS = {}

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
   
  def initialize(comment, *opt_fields)
    @fields = {}
    add_field(2, :Z, comment, /.*/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
