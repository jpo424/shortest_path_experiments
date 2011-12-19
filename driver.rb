#!/usr/bin/env ruby
require "rubygems"
require_relative "graph/weighted_directed_graph"
require_relative "graph/helpers"
require_relative "algorithms/algorithms"
require 'timeout'
require 'fileutils'

# this class exercises the algorithms to find its breaking points
# and runs the demo of each algo with input & output files
class Driver
  
  include Graph
  include Algorithms
  include Helpers
  
  TEST_DIRECTORY = 'project_testing'
  
  # stores a symbol that denotes the algo this instance tests
  # graphs is an array of graphs that can be passed in for running demo
  attr_accessor :algorithm, :graphs
  
  def initialize(algorithm,graphs=[])
    @algorithm = algorithm
    @graphs = graphs
  end
  
   # executes all 3 algos against 3 graphs
   # from a file and writes output to files
   # one per algo per graph
   # directory - directory for all output
   # graph_sizes - array of graph sizes you want to test against
  def self.run_demos(directory,graph_sizes=[500,1000,2000])
    demo_driver = Driver.new(nil)
    dir = "#{directory}/#{TEST_DIRECTORY}"
    # remove the test directory that lives in the given dir
    FileUtils.rm_r(dir, :force => true)
    # create the new directory
    FileUtils.mkdir(dir)
    # generate the 3 graphs, write them to files, but keep in mem. too
    graphs = []
    graph_sizes.each do |n|
      # generate a graph of each size
      graph_hash = demo_driver.generate_graph_hash(n)
      #write the graph to a file
      demo_driver.graph_hash_to_file("#{dir}/graph_size_#{n}", graph_hash)
      graphs << WeightedDirectedGraph.build(graph_hash)
    end
    # run the demo for each algo, passing in the graphs generated above
    Driver.new(:dijkstra,graphs).run_demo(dir)
    Driver.new(:shortest_path_with_topsort,graphs).run_demo(dir)
    Driver.new(:bellman_ford,graphs).run_demo(dir)
  end
  
  # tests an algo against 3 graphs of different sizes,
  # from 3 different input files
  # and produces 3 different output files
  # named: <algo_name>_<graph_input_size>.txt
  # directory - place to save output files
  def run_demo(directory)
    # uses graphs passed to driver class when instantiated
    @graphs.each do |graph|
      before = Time.now
      vertex_states = self.send(@algorithm,graph,0)
      after = Time.now
      running_time = after - before
      n = graph.vertices.count
      end_vertex = n - 1
      # reconstructs the path from the processed vertex states
      path = construct_path(vertex_states,end_vertex)
      # get the cost from the last node in the graph
      total_cost = vertex_states[end_vertex].shortest_distance
      # write to file the path and cost
      output_to_file(directory,@algorithm, path, total_cost,end_vertex, running_time)
    end
  end
  
  # ensures we build drivers only for shortest path algorithms
  def method_missing(meth, *args, &block)
    if meth == @algorithm
      puts "You tried to run a driver instance for a non existent algorithm: #{meth}"
      puts "Please build your driver from one of the algorithms below..."
      puts Algorithms.public_instance_methods
    end
    super
  end
  
  # finds breaking point of this driver's algo given
  # fail_period - max algo running time before considered broken
  def find_breaking_point(fail_period=5)
    determine_breaking_point(fail_period)
  end
  
  private
  
  # find the breaking point of a shortest path algo recursively
  def determine_breaking_point(fail_period=5,n=500, threshold_test=false,first_fail=nil,lower_n = 450, prev_success=true)
    puts "Current Graph Size: #{n}"
    # generates a graph of size n
    graph = WeightedDirectedGraph.build(generate_graph_hash(n))
    # executes the shortest path algorith associated with this driver class
    begin
      Timeout::timeout(fail_period) do
        self.send(@algorithm,graph,0)
      end
      success = true
    rescue Timeout::Error => e
      success = false
      unless threshold_test
        first_fail = n
        threshold_test = true
      end
    end
    # failed once, need to narrow down true breaking point
    if threshold_test
      if lower_n == (n - 1)
        return n
      elsif success
        determine_breaking_point(fail_period, n, threshold_test,first_fail,(n + lower_n)/2 ,success)
      else
        determine_breaking_point(fail_period, (n + lower_n)/2, threshold_test,first_fail, lower_n,success)
      end
    else
      # grow the graph by a large amount when we have yet to fail...proportionate to the fail_period
      determine_breaking_point(fail_period, n + (50 * fail_period), threshold_test,first_fail,n,success)
    end
  end
end

task = ARGV[0]
unless task.nil?
  if task == 'demo_all'
    dir = ARGV[1]
    if dir.nil?
      puts "ERROR: please enter a valid directory for aglorithm demo output"
    else
      puts "Executing Algorithm demos for graph sizes: [500,1000,1500]..."
      Driver.run_demos(dir,[500,1000,1500])
    end
  elsif task == 'break'
    algo = ARGV[1]
    if algo.nil?
      puts "ERROR: please enter a valid algorithm as the second argument"
      puts Algorithms.public_instance_methods
    else
      fail_period = ARGV[2]
      if fail_period.nil?
        puts "Finding breaking point for #{algo}"
        breaking_point = Driver.new(algo.to_sym).find_breaking_point
      else
        puts "Finding breaking point for #{algo} given max time of: #{fail_period}"
        breaking_point = Driver.new(algo.to_sym).find_breaking_point(fail_period.to_i)
      end
      puts "Breaking Point: #{breaking_point}"
    end
  end
end


















