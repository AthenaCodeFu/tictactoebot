
class InteractivePlayerInterface

  def readline
    $stdin.gets
  end

  def print(msg)
    system('clear')
    $stdout.print msg
  end

  def interactive?
    true
  end

end



class BotPlayerInterface

  attr_accessor :show_communication

  def initialize(to_bot_write, from_bot_read)
    @to_bot_write = to_bot_write
    @from_bot_read = from_bot_read
    @show_communication = false
  end

  def readline
    puts "*** #readline" if show_communication
    response = @from_bot_read.gets
    puts "<<< #{response}" if show_communication
    response
  end

  def print(msg)
    puts msg.lines.map {|s| ">>> #{s}"}.join if show_communication
    @to_bot_write.print(msg)
    @to_bot_write.flush
  end

  def interactive?
    false
  end

  @@pids = []

  # start the player bot in a new process and return an interface connected to it
  def self.start_bot(command)
    to_bot_read, to_bot_write = IO.pipe
    from_bot_read, from_bot_write = IO.pipe

    @@pids << fork do
      STDIN.reopen(to_bot_read)
      STDOUT.reopen(from_bot_write)
      exec(command)
    end

    to_bot_read.close
    from_bot_write.close

    return self.new(to_bot_write, from_bot_read)
  end

  # kill all subprocesses and wait for them to end
  def self.end_bots
    @@pids.each {|pid| Process.kill('KILL', pid) }
    @@pids.each {|pid| Process.wait(pid)         }
    @@pids.clear
  end

end
