class GFA::Record::Segment < GFA::Record
   CODE = :S
   REQ_FIELDS = [:name, :sequence]
   OPT_FIELDS = {
      :LN => :i,
      :RC => :i,
      :FC => :i,
      :KC => :i
   }

   REQ_FIELDS.each_index do |i|
      define_method(REQ_FIELDS[i]) { fields[i+2] }
   end
   
   def initialize(name, sequence, *opt_fields)
      @fields = {}
      add_field(2, :Z, name, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, sequence, /^\*|[A-Za-z=.]+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end

end
