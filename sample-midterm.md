### Intro to Operating Systems

[sample midtem](https://classroom.udacity.com/courses/ud923/lessons/3372168876/concepts/35205188490923)

#### 1. Process Creation
How is a new process created? Select all that apply.

- Via fork
- Via exec
- Via fork followed by exec
- Via exec followed by fork
- Via exec or fork followed by exec
- Via fork or fork followed by exec
- None of the above
- All of the above

#### 2. Multi-Threading and 1 CPU
Is there a benefit of multithreading on 1 CPU?

- Yes
- No

Give 1 reason to support your answer.

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
} // end producer code

// Consumer Code
while (more_to_consume) {
	mutex_lock(&m);
	if (out == in) // buffer empty 
		condition_wait(&not_empty);
	remove_item(out);
		out = (out + 1) % BUFFERSIZE; 
		condition_signal(&not_empty);    
} // end consumer code
```
#### 4. Calendar Critical Section
A shared calendar supports three types of operations for reservations:

- read
- cancel
- enter
Requests for cancellations should have priority above reads, who in turn have priority over new updates.

In pseudocode, write the critical section enter/exit code for the read operation

#### 5. Signals
If the kernel cannot see user-level signal masks, then how is a signal delivered to a user-level thread (where the signal can be handled)?

#### 6. Solaris Papers
The implementation of Solaris threads described in the paper "Beyond Multiprocessing: Multithreading the Sun OS Kernel", describes four key data structures used by the OS to support threads.

For each of these data structures, list at least two elements they must contain:

- Process
- LWP
- Kernel-threads
- CPU

#### 7. Pipeline Model
An image web server has three stages with average execution times as follows:

- Stage 1: read and parse request (10ms)
- Stage 2: read and process image (30ms)
- Stage 3: send image (20ms)
You have been asked to build a multi-threaded implementation of this server using the pipeline model. Using a pipeline model, answer the following questions:

How many threads will you allocate to each pipeline stage?
What is the expected execution time for 100 requests (in sec)?
What is the average throughput of the system in Question 2 (in req/sec)? Assume there are infinite processing resources (CPU's, memory, etc.).

#### 8. Performance Observations
Here is a graph from the paper [Flash: An Efficient and Portable Web Server](https://s3.amazonaws.com/content.udacity-data.com/courses/ud923/references/ud923-pai-paper.pdf), that compares the performance of Flash with other web servers.
![graph](https://s3.amazonaws.com/content.udacity-data.com/courses/ud923/notes/ud923-p2l5-bandwidth-vs-data-set-size.png)

For data sets where the data set size is less than 100 MB why does...

Flash perform worse than SPED?
Flash perform better than MP?