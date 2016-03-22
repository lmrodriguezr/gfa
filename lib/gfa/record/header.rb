class GFA::Record::Header < GFA::Record
   CODE = :H
   OPT_FIELDS = {
      :VN => :Z
   }
   def initialize(*opt_fields)
      @fields = {}
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end
end
