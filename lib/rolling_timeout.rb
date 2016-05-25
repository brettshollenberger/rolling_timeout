require "timeout"

class RollingTimeout
  attr_accessor :current_timeout, :threads, :options, :timeout
  attr_reader :worker_block

  def initialize(options = {}, &block)
    @current_timeout = 0
    @threads         = []
    @timeout         = options[:timeout] || 1
    @options         = options
    @worker_block    = block
  end

  def run
    @timeout_thread = Thread.new do
      new_timeout
    end

    @worker_thread = Thread.new do
      @result = worker_block.call(self)
    end

    @worker_thread.join
    return @result, @error
  ensure
    cleanup
  end

  def new_timeout
    @current_timeout += 1
    this_timeout = @current_timeout
    puts "Timeout #{this_timeout} started"

    begin
      Timeout::timeout(timeout) { sleep 9999999999999999 } 
    rescue => e
      puts "Timeout #{this_timeout} ended"

      if @current_timeout == this_timeout
        puts "Killed by timeout #{@current_timeout}"
        @error = Timeout::Error.new
        @worker_thread.kill
        @worker_thread.join
      end
    end
  end

  def reset
    old_timeout_thread = @timeout_thread

    @timeout_thread = Thread.new do
      new_timeout
    end

    kill_thread(old_timeout_thread)
  end

  def done
    kill_thread(@timeout_thread)
  end

  def kill_thread(thread)
    if thread && thread.alive?
      thread.kill
      thread.join
    end
  end

  def cleanup
    kill_thread(@timeout_thread)
    kill_thread(@worker_thread)
  end
end
