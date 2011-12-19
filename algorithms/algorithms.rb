require_relative '../graph/weighted_directed_graph'
require 'rgl'
require 'pqueue'

module Algorithms
  
  include Graph
  
  INFINITY = 1.0/0
  
  # models common things we'll need to know about vertices during
  # execution
  class VertexState
    
    attr_accessor :shortest_distance, :predecessor, :visited, :vertex
    
    def initialize(vertex)
      @shortest_distance = INFINITY
      @predecessor = nil
      @visited = false
      @vertex = vertex
    end
    
  end
  
  def bellman_ford(graph, source)
    n = graph.vertices.count
    # init vertex states for each vertexO(V)
    vertex_states = Hash.new{ |hash,key| hash[key] = VertexState.new(key)}
    graph.each_vertex do |vertex|
      vertex_states[vertex]
    end
    
    # handle the source node
    vertex_states[source].shortest_distance = 0
    vertex_states[source].visited = true
    
    #O(VE)
    1.upto(n - 1).each do |i|
      graph.each_edge do |u,v|
        relax(graph,u,v,vertex_states)
      end
    end
    vertex_states
  end
  
  # WeightedDirectedGraph, source => list of VertextState
  def shortest_path_with_topsort(graph, source)
    n = graph.vertices.count
    # an iterator that helps us go through vertices
    # in topo order
    #O(V+E)
    topsort_iter = RGL::TopsortIterator.new(graph)
    
    #O(V)
    # init vertex states for each vertex
    vertex_states = Hash.new{ |hash,key| hash[key] = VertexState.new(key)}
    graph.each_vertex do |vertex|
      vertex_states[vertex]
    end
    
    # handle the source node
    vertex_states[source].shortest_distance = 0
    vertex_states[source].visited = true
    
    #O(V + E)
    topsort_iter.each do |u|
      vertex_states[u].visited = true
      graph.each_adjacent(u) do |v|
        relax(graph,u,v,vertex_states)
      end
    end
    vertex_states
  end
  
  # WeightedDirectedGraph, source => list of VertextState
  def dijkstra(graph, source)
    # number of vertices in graph
    n = graph.vertices.count
    # O(V)
    # a hash of vertex_states for each vertex in graph
    vertex_states = Hash.new{ |hash,key| hash[key] = VertexState.new(key)}
    graph.each_vertex do |vertex|
      vertex_states[vertex]
    end
    
    # init rules for priority queue
    pqueue = PQueue.new(){|u,v| vertex_states[u].shortest_distance < vertex_states[v].shortest_distance }
    # handle the source node
    vertex_states[source].shortest_distance = 0
    vertex_states[source].visited = true
    pqueue.push(source)
    
    # O(VlogV + E)
    # main loop of algo
    while pqueue.size != 0
      # O(logV)
      u = pqueue.pop
      # set vertex state to visited
      vertex_states[u].visited = true
      # check adjacent vertices
      # O(E)
      graph.each_adjacent(u) do |v|
        relax(graph,u,v,vertex_states) {pqueue.push(v)}
      end
    end
    vertex_states
  end
  
  private
  
  def relax(graph,u,v,vertex_states, &block)
    edge_weight = graph.weight_for_edge([u,v])
    current_vertex_dist = vertex_states[u].shortest_distance
    adjacent_vertex_dist = vertex_states[v].shortest_distance
    if  adjacent_vertex_dist > ( current_vertex_dist + edge_weight) && !vertex_states[v].visited
      vertex_states[v].shortest_distance = current_vertex_dist + edge_weight
      vertex_states[v].predecessor = u
      # if there is some algo specific thing to do, execute here
      yield if block_given?
    end
  end
  
end

