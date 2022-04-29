# Job Contracts

## Test-like guarantees for jobs

Have you ever wanted to prevent a background job from writing to the database?
What about ensuring it completes within a fixed amount of time after being enqueued?

Contracts allow you to easily apply guarantees like this.

## Quick Start

Imagine you need to ensure a particular job always completes within 5 seconds of being enqueued.

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
One set dedicated to low-latency jobs with plenty of cpus, processes, threads, etc...
Another set dedicated to jobs with a higher tolerance for latency using less resources.

<img width="652" alt="Untitled 2 2022-04-29 14-33-01" src="https://user-images.githubusercontent.com/32920/166065341-65ff77e9-9123-4a3a-83c7-46dc91df6677.png">

In this scenario, we might determine the best jobs for the low-latency set should be limited to jobs that don't write to the database.

We might use a [`ReadOnlyContract`](https://github.com/hopsoft/job_contracts/blob/main/lib/job_contracts/contracts/read_only_contract.rb)
to ensure that jobs enqueued to low-latency queues don't write to the database.
If the contract is ever breached, we could notify our apm/monitoring service and re-enqueue the work to a high-latency queue.
This would raise awareness about the misconfiuration while ensuring that the work is still peformed.

## More Examples

## Sidekiq

## Todo

- [x] ActiveJob tests
- [ ] Sidekiq tests
- [-] Documentation

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
