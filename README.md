# Rolling Timeout

Receive chunked responses with timeouts.

```ruby
value, error = RollingTimeout.new(timeout: 0.5) do |timeout_manager|
  until remote_api.finished?
    remote_api.call do |chunk|
      timeout_manager.reset # Reset the timeout whenever we receive a chunk of data
      chunk
    end
  end

  timeout_manager.done  # Stop the timeouts; we've received all our data!

  remote_calls.response # The value we intend to return, unless a timeout causes us to return a Timeout::Error
end.run
```

== Copyright

Copyright (c) 2016 brettcassette. See LICENSE.txt for
further details.

