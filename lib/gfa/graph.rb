require "rgl/adjacency"
require "rgl/implicit"

class GFA
   def adjacency_graph
      implicit_graph.to_adjacency
   end
   
   def implicit_graph
      rgl_implicit_graph
   end

   private
   
      def segment_names_with_orient
	 segments.map do |s|
	    %w[+ -].map{ |orient| GFA::GraphVertex.idx(s, orient) }
	 end.flatten(1).to_set
      end

      def rgl_implicit_graph
	 RGL::ImplicitGraph.new do |g|
	    g.vertex_iterator do |b|
	       segment_names_with_orient.each &b
	    end
	    g.adjacent_iterator do |x,b|
	       links.each do |l|
		  if l.from?(x.segment, x.orient)
		     b.call(GFA::GraphVertex.idx(l.to, l.to_orient))
		  elsif GraphVertex.orient? and
				    l.to?(x.segment, x.orient=="+" ? "-" : "+")
		     b.call(GFA::GraphVertex.idx(l.from,
			l.from_orient.value=="+" ? "-" : "+"))
		  end
	       end
	    end
	    g.directed = GFA::GraphVertex.orient?
	 end
      end

end

class GFA::GraphVertex
   # Class-level
   @@idx = {}
   @@orient = true
   def self.idx(segment, orient)
      n = GFA::GraphVertex.new(segment, orient)
      @@idx[n.to_s] ||= n
      @@idx[n.to_s]
   end
   def self.orient? ; @@orient ; end
   def self.orient!(v) @@orient=v ; end
   
   # Instance-level
   attr :segment, :orient
   def initialize(segment, orient)
      @segment = segment.is_a?(GFA::Record::Segment) ? segment.name.value :
		  segment.is_a?(GFA::Field) ? segment.value : segment
      @orient  = !self.class.orient? ? nil :
		  orient.is_a?(GFA::Field) ? orient.value : orient
   end

   def to_s
      "#{segment}#{orient}"
   end

end
