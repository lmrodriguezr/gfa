require "gfa/version"
require "gfa/record"
require "gfa/field"

class GFA
   
   # Class-level
   def self.assert_format(value, regex, message)
      unless value =~ regex
         raise "#{message}: #{value}."
      end
   end

   # Instance-level
   attr :gfa_version, :records
   GFA::Record.TYPES.each do |r_type|
      plural = "#{r_type.downcase}s"
      singular = "#{r_type.downcase}"
      define_method(plural) do
         records[r_type]
      end
      define_method(singular) do |k|
         records[r_type][k]
      end
      define_method("add_#{singular}") do |v|
         @records[r_type] << v
      end
   end

   def initialize
      @records = {}
      GFA::Record.TYPES.each { |t| @records[t] = [] }
   end
   
   def empty?
      records.values.all? { |r| r.empty? }
   end

   def eql?(gfa)
      records == gfa.records
   end

   alias == eql?
   
end
