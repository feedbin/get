module Get
  class Timeout
    def initialize(timeout = 0)
      @deadline = now + timeout.to_f
    end

    def timed_out?
       now > @deadline
    end

    def now
      ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    end
  end
end

