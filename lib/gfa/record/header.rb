class GFA::Record::Header < GFA::Record
   CODE = :H
   REQ_FIELDS = []
   OPT_FIELDS = {
      :VN => :Z
   }
   
   REQ_FIELDS.each_index do |i|
      define_method(REQ_FIELDS[i]) { fields[i+2] }
   end
   
   def initialize(*opt_fields)
      @fields = {}
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end

end
