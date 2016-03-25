require "gfa/common"
require "gfa/parser"
require "gfa/generator"
require "gfa/graph"

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
