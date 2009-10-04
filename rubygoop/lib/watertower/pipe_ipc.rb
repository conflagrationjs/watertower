require 'pathname'

module Watertower
  class PipeIPC
    attr_reader :input_pipe, :output_pipe, :pipe_dir
    
    def initialize(options)
      options = {:create => true}.merge(options)
      @pipe_dir = Pathname(options[:pipe_dir]).expand_path
      raise IOError, "Given pipe dir '#{@pipe_dir}' is not writable" unless @pipe_dir.writable?
      
      @input_pipe, @output_pipe = pipe_path(options[:namespec], "input"), pipe_path(options[:namespec], "output")
      create_pipes if options[:create]
    end
    
  private
    
    def pipe_path(namespec, direction)
      (pipe_dir + ((namespec % Process.pid) + ".#{direction}.pipe")).expand_path
    end
    
    def create_pipes
      [@input_pipe, @output_pipe].each { |pipe_path| mkfifo(pipe_path) }
    end

    def mkfifo(path)
      %x[mkfifo -m 600 "#{path}"]
    end
    
  end # PipeIPC
end   # Watertower