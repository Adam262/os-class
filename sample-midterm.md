### Intro to Operating Systems

[sample midtem](https://classroom.udacity.com/courses/ud923/lessons/3372168876/concepts/35205188490923)

#### 1. Process Creation
How is a new process created? Select all that apply.

- Via fork (copy parent PCB to new child PCB, then parent and child operate simultaneously) - X
- Via exec (replaces current process with a new process, then never returns to parent)
- Via fork followed by exec - X
- Via exec followed by fork
- Via exec or fork followed by exec
- Via fork or fork followed by exec - X
- None of the above
- All of the above 

#### 2. Multi-Threading and 1 CPU
Is there a benefit of multithreading on 1 CPU?

- Yes - X
- No

The benefit is maximizing CPU utiliziation. If a thread is blocked, the OS scheduler can give priority to another thread. The CPU is therefore better able to multitask. Although it cannot run two threads simultaneously, it can be scheduled to switch between them so fast that they seem to run in parallel.  In this way, the CPU spends less time dormant. 

#### 3. Critical Section
In the (pseudo) code segments for the producer code and consumer code, mark and explain all the lines where there are errors.

```
// Global Section
int in, out, buffer[BUFFERSIZE];
mutex_t m;
cond_var_t not_empty, not_full;

// Producer Code
while (more_to_produce) {
  mutex_lock(&m);
  if (out == (in + 1) % BUFFERSIZE)) // buffer full 
    condition_wait(&not_full);
  add_item(buffer[in]); // add item
    in = (in + 1) % BUFFERSIZE 
    cond_broadcast(&not_empty);  

  // never unlocks mutex

} // end producer code

// Consumer Code
while (more_to_consume) {
  mutex_lock(&m);
  if (out == in) // buffer empty 
    condition_wait(&not_empty);
  remove_item(out);
    out = (out + 1) % BUFFERSIZE; 
    condition_signal(&not_empty); 

  // never unlocks mutex
   
} // end consumer code
```
#### 4. Calendar Critical Section
A shared calendar supports three types of operations for reservations:

- read
- cancel
- enter
Requests for cancellations should have priority above reads, who in turn have priority over new updates.

In pseudocode, write the critical section enter/exit code for the read operation

```
mutex_t m
cond_var_t can_update, cancelling

// reader code

while (!cancelling) {
  mutex_lock(&m);
  read_reservation;

  condition_signal(&can_update); 
  
  mutex_unlock(&m)
} // end reader code
```

#### 5. Signals
If the kernel cannot see user-level signal masks, then how is a signal delivered to a user-level thread (where the signal can be handled)?

The kernel signals the ULT library. The library has a signal handler, which has
visibility to the masks of the ULT. So the library updates the signal mask of the ULT

#### 6. Solaris Papers
The implementation of Solaris threads described in the paper "Beyond Multiprocessing: Multithreading the Sun OS Kernel", describes four key data structures used by the OS to support threads.

For each of these data structures, list at least two elements they must contain:

- Process
  - List of corresponding kernel-threads
  - Virtual address space mappings
  - User credentials (eg, if process can access file)
  - List of signal handlers
- LWP (relavant for subset of processes)
  - Similar to ULT but visible to kernel for scheduler
  - Signal mask
  - System call args
  - User level registers
  - Pointers to kernel thread / process
  - Swappable
- Kernel level threads
  - Kernel level registers
  - Stack pointer
  - Scheduling info
  - Pointers to stack, LWP, CPU   
  - Not swappable
- CPU
  - Pointers to currently executing thread, idle thread
  - List of other idle KLT
  - List of dispatch / interrupt handlers
  - For SPARC architecture, there is a dedicated register to point to current thread

#### 7. Pipeline Model
An image web server has three stages with average execution times as follows:

- Stage 1: read and parse request (10ms)
- Stage 2: read and process image (30ms)
- Stage 3: send image (20ms)

You have been asked to build a multi-threaded implementation of this server using the pipeline model. Using a pipeline model, answer the following questions:

How many threads will you allocate to each pipeline stage?

Stage 1: 1 thread
Stage 2: 3 threads
Stage 3: 2 threads
    
    10   20   30    40     50
1   X     X    X     X     X
2         XX   XXX   XXX   XXX
3                    X     XX
What is the expected execution time for 100 requests (in sec)? 60 X (99 * 10) = 1050ms = 1.05s
What is the average throughput of the system in Question 2 (in req/sec)? Assume there are infinite processing resources (CPU's, memory, etc.). 100 req / 1.05s

#### 8. Performance Observations
Here is a graph from the paper [Flash: An Efficient and Portable Web Server](https://s3.amazonaws.com/content.udacity-data.com/courses/ud923/references/ud923-pai-paper.pdf), that compares the performance of Flash with other web servers.
![graph](https://s3.amazonaws.com/content.udacity-data.com/courses/ud923/notes/ud923-p2l5-bandwidth-vs-data-set-size.png)

For data sets where the data set size is less than 100 MB why does...

Flash perform worse than SPED?
- at under 100MB, data is the cache
- so basic SPED model is most efficient. 
- There are no I/O calls so you don't need the optimizations of other models that hanbdle blocking
- These optimizations have overhead such as memory checks
Flash perform better than MP?
- Flash is single threaded and event driven
- an MP model has more context switching
