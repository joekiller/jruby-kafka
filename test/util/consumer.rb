DEFAULT_CLIENT_OPTIONS = {
    :zookeeper_connect => '127.0.0.1:2181',
    :group_id => 'test',
    :topic => 'test',
    :auto_offset_reset => 'smallest'
}

def consumer_options(opt_override = nil)
  if opt_override.nil?
    DEFAULT_CLIENT_OPTIONS
  else
    DEFAULT_CLIENT_OPTIONS.merge(opt_override)
  end
end

def filter_consumer_options(opt_override = nil)
  options = consumer_options opt_override
  options.delete(:topic)
  options
end


def consumer_test_blk(stream, queue)
  it = stream.iterator
  begin
    queue << it.next.message.to_s while it.hasNext
  rescue Exception => e
    sleep 1
    retry
  end
end
