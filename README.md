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
  after_contract_breach :contract_breached

  def perform
    # logic...
  end

  private

  def contract_breached(contract)
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

We might determine that low-latency jobs should not write to the database for this formation.

We could use a [`ReadOnlyContract`](https://github.com/hopsoft/job_contracts/blob/main/lib/job_contracts/contracts/read_only_contract.rb) for this.
If the contract is breached, we will notify our apm/monitoring service and re-enqueue the work to a high-latency queue.
This behavior would raise awareness about the misconfiguration while ensuring that the work is still performed.

Here's an example job implementation that accomplishes this.

```ruby
class FastJob < ApplicationJob
  include JobContracts::Contractable

  queue_as :critical

  # NOTE: the ReadOnlyContract only enforces on the queue configured above
  add_contract JobContracts::ReadOnlyContract.new
  after_contract_breach :contract_breached

  def perform(contracts_to_skip=nil)
    # logic that doesn't write to the database
  end

  private

  def contract_breached(contract)
    # log and notify apm/monitoring service

    # re-enqueue to the queue expected by the contract
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
