require 'fileutils'

module Helpers
  
  # returns an array that is the path from source to destination
  def construct_path(vertex_states, end_vertex, path=[0])
    vertex_state = vertex_states[end_vertex]
    predecessor = vertex_state.predecessor
    predecessor_state = vertex_states[predecessor]
    unless predecessor_state.shortest_distance == 0
      construct_path(vertex_states, predecessor, path)
    end
    path << end_vertex
  end
  
  # generates a graph up to N vertices
  def generate_graph_hash(n)
    edges_weights = {}
    # go through all vertices and generate random edges/ weights
    0.upto(n - 1) do |u|
      # create an edge from this node to the next
      # generate weight for the new edge
      weight = rand(n)
      # create an edge to next vertex...easy way to ensure connectivity
      v = u + 1
      edge = [u, v]
      edges_weights[edge] = weight
      # create an alternative edge...randomly
      if (rand(n) % 2) == 0 && u < (n - 1)
        alt_weight = Random.new.rand(weight+1..n)
        alt_v = Random.new.rand(v+1..n)
        alt_edge = [u, alt_v]
        edges_weights[alt_edge] = alt_weight
      end
    end
    edges_weights
  end
  
  # writes a graph to a txt file
  def graph_hash_to_file(file_path, graph_hash)
    file = File.new("#{file_path}.txt", "w")
    graph_hash.keys.each do |edge|
      weight = graph_hash[edge]
      u = edge[0]
      v = edge[1]
      file.puts "#{u},#{v}=#{weight}"
    end
  end
  
  # writes an algorithm's output to a file
  def output_to_file(dir,algorithm, path, cost,n, running_time)
   file_path = "#{dir}/#{algorithm.to_s}_#{n}_output.txt"
   FileUtils.rm file_path, :force => true
   file = File.new(file_path, "w")
   # write the path to file
   path.each do |vertex|
    file.puts "#{vertex}"
   end
   file.puts "Total Cost: #{cost}"
   file.puts "Running Time: #{running_time}"
  end
  
end
