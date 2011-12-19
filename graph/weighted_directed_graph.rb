require 'rgl'

module Graph
  
  class WeightedDirectedGraph < RGL::DirectedAdjacencyGraph
  
    attr_accessor :weight_table
  
    # Construct a weighted DAG
    # hash of form {[v1,v2]=>weight}  ===>  Weighted Graph
    def self.build (edge_hash)
      result = new
      edge_hash.each do |edge,weight|
        result.add_edge(edge[0], edge[1]) 
      end
      # add the weight table as an attribute
      result.weight_table = edge_hash
      result
    end
    
    # simply abstracts hash lookup
    def weight_for_edge(edge)
      @weight_table[edge]
    end
  
  end

end
