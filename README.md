# Job Contracts

## Test-like guarantees for jobs

Have you ever wanted to prevent a background job from writing to the database?
What about ensuring it completes within a fixed amount of time after being enqueued?

Contracts allow you to apply guarantees like this easily.

## Quick Start

Imagine you need to ensure a specific job type completes within 5 seconds of being enqueued.

```ruby
class ImportantJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :default

  add_contract JobContracts::DurationContract.new(duration: 5.seconds)

  def perform
    # logic...
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service
  end
end
```

## Benefits

- Move unrelated concerns out of the job
- Simplify logic for better maintainability
- Isolate platform mechanics such as
  - Enforcing and tracking SLAs/SLOs/SLIs
  - Telemetry and instrumentation
  - Helping to inform worker formation/topology and system design

## Worker Formations (Operational Topology)

Thoughtful Rails applications often use specialized worker formations.

A simple formation might be to use two sets of workers.
One set is dedicated to low-latency jobs with plenty of CPUs, processes, threads, etc...,
while another set is dedicated to jobs with a higher tolerance for latency.

<img width="593" alt="Untitled 2 2022-04-29 15-06-13" src="https://user-images.githubusercontent.com/32920/166069103-e316dcc7-e601-43d0-90df-ad0eda20409b.png">

Perhaps we determine that low-latency jobs should not write to the database.
We can use a [`ReadOnlyContract`](https://github.com/hopsoft/job_contracts/blob/main/lib/job_contracts/contracts/read_only_contract.rb)
to enforce this decision. If the contract is breached, we will notify our apm/monitoring service and re-enqueue the work to a high-latency queue.
This behavior will raise awareness about the misconfiguration while ensuring the job is still performed.

Here's an example job implementation that accomplishes this.

```ruby
class FastJob < ApplicationJob
  include JobContracts::Contractable

  # Configure the queue before adding contracts
  # It will be used as the default enforcement queue for contracts
  queue_as :critical

  # Only enforces on the critical queue
  # This allows us to halt job execution and reenqueue the job to a different queue
  # where the contract will not be enforced
  #
  # NOTE: the arg `queues: [:critical]` is default behavior in this example
  #       we're setting it explicitly here for illustration purposes
  add_contract JobContracts::ReadOnlyContract.new(queues: [:critical])

  def perform(contracts_to_skip=nil)
    # logic that shouldn't write to the database,
    # but might accidentally due to complex or opaque internals
  end

  def contract_breached!(contract)
    # log and notify apm/monitoring service

    # re-enqueue to a different queue
    # where the database write will be permitted
    # i.e. where the contract will not be enforced
    enqueue queue: :default
  end
end
```

## More Examples

## Sidekiq

## Todo

- [x] ActiveJob tests
- [ ] Sidekiq tests
- [ ] Documentation

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
