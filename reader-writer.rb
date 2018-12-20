
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

# Key takeaway
# - counter_mutex is over resource counter
# - condition variable is over critical section

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
  # NUM_WRITERS = 5

  SHARED_VALUE = 0

  def call
    threads = []
    i = 0

    while i < NUM_READERS do
      i += 1
      
      thread = Thread.new do
        reader.read
      end

      threads << thread
    end
    
    threads.each(&:join)
  end

  private 

  def reader
    Reader.new(
      counter_mutex: resource_counter_mutex,
      service: service,
      reader_condition: reader_condition,
      writer_condition: writer_condition,
    )
  end
  
  # def writer
  #   Writer.new(
  #     mutex: resource_counter_mutex,
  #     service: service,
  #     condition: writer_condition,
  #   )
  # end
  
  def resource_counter_mutex
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
  def initialize
    @resource_counter = ReaderWriter::RESOURCE_COUNTER
    @shared_value = ReaderWriter::SHARED_VALUE
  end

  def writeable?
    @resource_counter == 0
  end

  def readable?
    @resource_counter >= 0
  end
  
  def write_phase?
    @resource_counter == -1
  end

  def add_additional_reader
    @resource_counter += 1
  end

  def remove_reader
    @resource_counter -= 1
  end 

  def set_sole_writer
    @resource_counter = -1
  end

  def remove_sole_writer
    @resource_counter = 0
  end

  def log_readers
    reader_count = @resource_counter <= 0 ? 0 : @resource_counter

    puts "There are #{reader_count} readers" 
  end

  def log_shared_value
    puts "The shared value is #{@shared_value}"
  end

  private

  attr_accessor :resource_counter, :shared_value
end

class Reader
  def initialize(counter_mutex:, service:, reader_condition:, writer_condition:)
    @counter_mutex = counter_mutex
    @service = service
    @reader_condition = reader_condition
    @writer_condition = writer_condition
  end

  def read
    counter_mutex.synchronize do
      # Wait to acquire lock while sole writer is writing
      reader_condition.wait(counter_mutex) while service.write_phase?

      service.add_additional_reader
    end

    service.log_readers
    service.log_shared_value

    counter_mutex.synchronize do
      service.remove_reader

      writer_condition.signal if service.writeable?
      reader_condition.broadcast if service.readable?
    end
  end

  private

  attr_reader :counter_mutex, :service, :reader_condition, :writer_condition
end

class Writer
  def initialize(counter_mutex:, service:, writer_condition:, reader_condition:)
    @counter_mutex = counter_mutex
    @service = service
    @writer_condition = writer_condition
    @reader_condition = reader_condition
  end

  def write
    counter_mutex.synchronize do
      # Wait to acquire lock until writer is free to write
      while !service.writeable? do
        writer_condition.wait(counter_mutex) 
      end
      
      service.set_sole_writer
    end

    # write random value to shared value

    counter_mutex.synchronize do
      service.remove_sole_writer

      reader_condition.broadcast
      writer_condition.signal
    end
  end

  # service.remove_sole_writer

  # reader_condition.broadcast

  private

  attr_reader :counter_mutex, :service, :writer_condition, :reader_condition
end

ReaderWriter.new.call
