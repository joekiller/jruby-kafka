def consumer_test(stream, thread_num, queue)
  it = stream.iterator
  queue << it.next.message.to_s while it.hasNext
  puts "Shutting down Thread: #{thread_num}"
end
