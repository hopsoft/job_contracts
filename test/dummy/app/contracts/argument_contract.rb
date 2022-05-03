# frozen_string_literal: true

class ArgumentContract < JobContracts::Contract
  def initialize(range:)
    super queues: ["*"], expected: {range: range}
  end

  def enforce!(contractable)
    actual[:argument] = contractable.arguments.first
    self.satisfied = expected[:range].cover?(actual[:argument])
    super
  end
end
