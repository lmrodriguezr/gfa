class GFA::Record::Comment < GFA::Record
  CODE = :'#'
  REQ_FIELDS = []
  OPT_FIELDS = {}
   
  def initialize(*opt_fields)
    @fields = {}
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
