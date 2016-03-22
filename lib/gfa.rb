require "gfa/version"
require "gfa/common"
require "gfa/record"
require "gfa/parser"
require "gfa/generator"

##
# = Graphical Fragment Assembly (GFA)
#
# To read about GFA visit: https://github.com/pmelsted/GFA-spec
#
# == Parsing GFA
#
# To parse a file in GFA format:
#
#   require "gfa"
#   
#   my_gfa = GFA.load("assembly.gfa")
#
# To load GFA strings line-by-line:
#
#   require "gfa"
#   
#   my_gfa = GFA.new
#   fh = File.open("assembly.gfa", "r")
#   fh.each do |ln|
#      my_gfa << ln
#   end
#   fh.close
#
# == Saving GFA
#
# After altering a GFA object, you can simply save it in a file as:
#
#    my_gfa.save("alt-assembly.gfa")
#
# Or line-by-line as:
#
#    fh = File.open("alt-assembly.gfa", "w")
#    my_gfa.each_line do |ln|
#       fh.puts ln
#    end
#    fh.close
#
class GFA
   # Instance-level
   attr :gfa_version, :records
   Record::TYPES.each do |r_type|
      plural = "#{r_type}s"
      singular = "#{r_type}"
      define_method(plural) do
	 records[r_type]
      end
      define_method(singular) do |k|
	 records[r_type][k]
      end
      define_method("add_#{singular}") do |v|
	 @records[f] << v
      end
   end
   def initialize
      @records = {}
      Record::TYPES.each { |t| @records[t] = [] }
   end
end
