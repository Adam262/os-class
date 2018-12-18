
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

class ReaderWriter
   require 'thread'

  # READ_COUNTER = 0
  # WRITE_COUNTER = 0

  # RESOURCE_COUNTER is a proxy for the state of readers and writers

  ## RC == 0 => resource is free for read and write
  ## RC > 0 => resource is free for read only
  ## RC == -1 => resource is not free for read or write
  RESOURCE_COUNTER = 0
  
  NUM_READERS = 5
  NUM_WRITERS = 5

  SHARED_VALUE = 0

  def call
    while i < NUM_READERS do
      i += 1
      
      reader.read
    end
  end

  private 

  def reader
    Reader.new(
      mutex: mutex,
      service: service,
      condition: reader_condition,
    )
  end
  
  def writer
    Writer.new(
      mutex: mutex,
      service: service,
      condition: reader_condition,
    )
  end
  
  def mutex
    @mutex ||= Mutex.new
  end

  def reader_condition
    @condition ||= ConditionVariable.new
  end

  def writer_condition
    @condition ||= ConditionVariable.new
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

  private

  def resource_counter
    ReaderWriter::RESOURCE_COUNTER
  end
end

class Reader
  def initialize(mutex:, service:, condition:)
    @mutex = mutex
    @service = service
    @condition = condition
  end

  def read
    thread do   
      mutex.synchronize do
        # Wait to acquire lock while sole writer is writing
        condition.wait(mutex) while service.write_phase?

        service.add_additional_reader
      end
    end
  end

  def read_end
    thread do   
      mutex.synchronize do
        service.remove_reader

        # signal if it is the last reader and RESOURCE_COUNTER is now zero
        condition.signal if writeable?
      end
    end
  end

  private

  attr_reader :mutex, :service, :condition

  def thread
    @thread ||= Thread.new
  end
end

class Writer
  def initialize(mutex:, service:, condition:)
    @mutex = mutex
    @service = service
    @condition = condition
  end

  def write
    thread do   
      mutex.synchronize do
        # Wait to acquire lock until writer is free to write
        condition.wait(mutex) unless service.writeable? do
        
        service.set_sole_writer
      end
    end
  end

  def write_end
    thread do   
      mutex.synchronize do
        service.remove_sole_writer

        condition.broadcast
      end
    end
  end

  private

  attr_reader :mutex, :service, :condition

  def thread
    @thread ||= Thread.new
  end

end

ReaderWriter.new.call
