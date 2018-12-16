
# Priority Readers and Writers
# Write a multi-threaded C program that gives readers priority over writers concerning a shared global) variable. Essentially, if any readers are waiting, then they have priority over writer threads -- writers can only write when there are no readers. This program should adhere to the following constraints:

# Multiple readers/writers must be supported (5 of each is fine)
# Readers must read the shared variable X number of times
# Writers must write the shared variable X number of times

# Readers must print:
# The value read
# The number of readers present when value is read

# Writers must print:
# The written value
# The number of readers present were when value is written (should be 0)
# Before a reader/writer attempts to access the shared variable it should wait some random amount of time

# Note: This will help ensure that reads and writes do not occur all at once
# Use pthreads, mutexes, and condition variables to synchronize access to the shared variable


# if READ_COUNTER == 0 && WRITE_COUNTER == 0 
#   # read ok
#   # write ok
# elsif READ_COUNTER > 0
#   # read ok
# elsif WRITE_COUNTER == 1
#   # read no
#   # write no
# end

# CounterMutex#synchronize { ... } => obtains a lock, runs the block, and releases the lock when the block completes
class CounterMutex < Mutex
end

class ReaderWriter
  # READ_COUNTER = 0
  # WRITE_COUNTER = 0

  # RESOURCE_COUNTER is a proxy for the state of readers and writers

  ## RC == 0 => resource is free for read and write
  ## RC > 0 => resource is free for read only
  ## RC == -1 => resource is not free for read or write
  RESOURCE_COUNTER = 0

  def call
  end

  private 

  def counter_mutex
    @counter_mutex ||= CounterMutex.new
  end

  def service
    @service ||= Service.new
  end

end

class Service
  def writeable?
    resource_counter == 0
  end

  def read_phase?
    resource_counter >= 0
  end
  
  def write_phase?
    resource_counter == -1
  end

  def add_additional_reader
    resource_counter += 1
  end

  def remove_reader
    resource_counter -= 1
  end 

  def set_sole_writer
    resource_counter = -1
  end

  def remove_sole_writer
    resource_counter = 0
  end

  def broadcast_read
    puts "Broadcasting read!"
  end

  def signal_write
    puts "Signaling write!"
  end

  private

  def resource_counter
    ReaderWriter::RESOURCE_COUNTER
  end
end

class Reader
  require 'thread'

  def initialize(mutex:, service:)
    @mutex = mutex
    @service = service
  end

  def read
    thread do   
      mutex.synchronize do
        # Release lock and sleep so sole writer can finish and decrement RESOURCE_COUNTER
        sleep while service.write_phase?

        service.add_additional_reader
      end
    end
  end

  def read_end
    thread do   
      mutex.synchronize do
        service.remove_reader

        # signal if it is the last reader and RESOURCE_COUNTER is now zero
        service.signal_write if writeable?
      end
    end
  end

  private

  attr_reader :mutex, :service

  def thread
    @thread ||= Thread.new
  end
end

class Writer
  require 'thread'

  def initialize(mutex:, service:)
    @mutex = mutex
    @service = service
  end

  def write
    thread do   
      mutex.synchronize do
        # Release lock and sleep so readers can finish and decrement RESOURCE_COUNTER
        sleep unless service.writeable? do
        
        service.set_sole_writer
      end
    end
  end

  def write_end
    thread do   
      mutex.synchronize do
        service.remove_sole_writer

        service.signal_write
        service.broadcase_read
      end
    end
  end

  private

  attr_reader :mutex, :service

  def thread
    @thread ||= Thread.new
  end

end

ReaderWriter.new.call
