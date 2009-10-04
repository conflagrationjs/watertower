require 'pathname'
require 'json/pure'
require 'fcntl'

module Watertower
  class PipeIPC
    attr_reader :input_pipe, :output_pipe, :pipe_dir, :lock_file
    
    def initialize(options)
      options = {:create => true}.merge(options)
      raise ArgumentError, ":pipe_dir must be given" unless options[:pipe_dir]
      raise ArgumentError, ":namespec must be given" unless options[:namespec]
      @pipe_dir = Pathname(options[:pipe_dir]).expand_path
      raise IOError, "Given pipe dir '#{@pipe_dir}' is not writable" unless @pipe_dir.writable?
      
      @input_pipe, @output_pipe = pipe_path(options[:namespec], "input"), pipe_path(options[:namespec], "output")
      @lock_file = create_lock_file(options[:namespec]) if options[:lock]
      create_pipes if options[:create]
    end
    
    def dispatch(message_object)
      with_locking do
        @output_pipe.open(Fcntl::O_WRONLY) {|p| p.puts(message_object.to_json) }
        if block_given?
          @input_pipe.open(Fcntl::O_RDONLY) {|p| yield(JSON.parse(p.readline)) }
        end
      end
    end
    
  private
    def with_locking
      return(yield) unless lock_file
      lock_file.open('w') do |lf|
        lf.flock(File::LOCK_EX)
        begin
          yield
        ensure
          lf.flock(File::LOCK_UN)
        end
      end
    end
    
    def create_lock_file(namespec)
      lock_file = (pipe_dir + ((namespec % Process.pid) + ".lock")).expand_path
      lock_file.open('w').close
      lock_file
    end
    
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