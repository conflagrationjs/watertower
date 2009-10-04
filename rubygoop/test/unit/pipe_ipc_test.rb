require 'test_helper'
require 'tmpdir'
require 'watertower/pipe_ipc'

context "a PipeIPC object" do
  make_pipe_dir = lambda do
    pipe_dir = (Pathname(Dir.tmpdir) + "wt_test#{Time.now.to_i}#{Process.pid}#{Time.now.usec}").expand_path
    pipe_dir.mkdir
    pipe_dir
  end
  
  context "with a writable pipe dir and no existing pipes and valid arguments" do
    setup do
      pipe_dir = make_pipe_dir.call
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower.%s")
    end
    
    should("have an accessor for the lock file that returns false as :lock is false by default") do
      topic.lock_file
    end.equals(nil)
    
    should("have an accessor for the pipe directory that returns a Pathname object") do
      topic.pipe_dir
    end.kind_of(Pathname)
    
    should("have an accessor for the input pipe that returns a Pathname object") do
      topic.input_pipe
    end.kind_of(Pathname)
    
    should("have an accessor for the output pipe that returns a Pathname object") do
      topic.output_pipe
    end.kind_of(Pathname)
    
    should("have created the input pipe") do
      topic.input_pipe.exist?
    end
    
    should("have created the output pipe") do
      topic.output_pipe.exist?      
    end
    
    should("have created the input pipe as a pipe") do
      topic.input_pipe.pipe?
    end
    
    should("have created the output pipe as a pipe") do
      topic.output_pipe.pipe?
    end
    
    should("have created the input pipe with the current pid in the name using the given namespec") do
      topic.input_pipe.basename.to_s
    end.matches(%r[watertower.#{Process.pid}.input.pipe])
    
    should("have created the output pipe with the current pid in the name using the given namespec") do
      topic.output_pipe.basename.to_s
    end.matches(%r[watertower.#{Process.pid}.output.pipe])
   
    should("have created the input pipe with permissions 0600") do
      sprintf("%o", topic.input_pipe.stat.mode)
    end.equals("10600")
    
    should("have created the output pipe with permissions 0600") do
      sprintf("%o", topic.output_pipe.stat.mode)      
    end.equals("10600")
  end # with a writable pipe dir and no existing pipes and valid arguments

  context "with a namespec without %s" do

    setup do
      pipe_dir = make_pipe_dir.call
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower")
    end
    
    should("not interpolate in the process id into the input pipe name") do
      topic.input_pipe.basename.to_s      
    end.matches("watertower.input.pipe")
    
    should("not interpolate in the process id into the output pipe name") do
      topic.output_pipe.basename.to_s
    end.matches("watertower.output.pipe")
        
  end # with a namespec without %s
  
  should("raise if not given a pipe_dir argument") do
    Watertower::PipeIPC.new(:namespec => "watertower")
  end.raises(ArgumentError, /:pipe_dir must be given/)
  
  should("raise if not given a namespec argument") do
    Watertower::PipeIPC.new(:pipe_dir => "/tmp/foo")
  end.raises(ArgumentError, /:namespec must be given/)
  
  context "with :create set to false" do
    setup do
      pipe_dir = make_pipe_dir.call
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower", :create => false)
    end
    
    should("not create the input pipe") do
      !topic.input_pipe.exist?
    end
    
    should("not create the output pipe") do
      !topic.output_pipe.exist?
    end
  end # with :create set to false
  
  context "with :create set to true but given a non-writable pipe dir" do
    should "raise an appropriate exception" do
      pipe_dir = make_pipe_dir.call
      pipe_dir.chmod(0)
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower")
    end.raises(IOError)
  end # with :create set to true but given a non-writable pipe dir

  context "when performing IPC with a PipeIPC object" do
    setup do
      pipe_dir = make_pipe_dir.call
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower.%s")
    end
    
    should("write the given message as JSON to the output pipe") do
      io = IO.popen("cat #{topic.output_pipe}")
      topic.dispatch(:foo => :bar)
      io.read
    end.equals("#{{:foo => :bar}.to_json}\n")
    
    should("call the given callback with the deserialized object") do
      IO.popen("cat #{topic.output_pipe} > /dev/null")
      io = IO.popen(%Q[cat > "#{topic.input_pipe}"], 'w')
      io.puts({:snafu => :qhat}.to_json)
      topic.dispatch(:foo => :bar) { |response| response }
    end.equals('snafu' => 'qhat')    
  end
  
  context "when performing IPC with a PipeIPC object with :lock set to true" do
    setup do
      pipe_dir = make_pipe_dir.call
      Watertower::PipeIPC.new(:pipe_dir => pipe_dir, :namespec => "watertower.%s", :lock => true)
    end
     
    should("have an accessor for the lock file that returns a Pathname object") do
      topic.lock_file
    end.kind_of(Pathname)
    
    should("create the lock file") do
      topic.lock_file.exist?
    end
    
    should("lock the lock file until the request/response cycle is done") do
      IO.popen("cat #{topic.output_pipe} > /dev/null")
      IO.popen(%Q[cat > "#{topic.input_pipe}"], 'w').puts({:snafu => :qhat}.to_json)
      thread = Thread.new do
        topic.dispatch(:foo => :bar) do |response|
          Thread.current['received'] = true
          nil until Thread.current['stop']
        end
      end
      nil until thread['received']
      locked = topic.lock_file.open('w') { |f| f.flock(File::LOCK_EX | File::LOCK_NB) == false }
      thread['stop'] = true
      thread.join
      locked
    end
    
    should("unlock the lock file when the request/response cycle is done") do
      IO.popen("cat #{topic.output_pipe} > /dev/null")
      IO.popen(%Q[cat > "#{topic.input_pipe}"], 'w').puts({:snafu => :qhat}.to_json)
      topic.dispatch(:foo => :bar)
      topic.lock_file.open('w') { |f| f.flock(File::LOCK_EX | File::LOCK_NB) == 0 }
    end
  end # when performing IPC with a PipeIPC object with :lock set to true
  
end