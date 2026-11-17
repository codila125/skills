# TDD

The loop is red → green, and it runs **vertically**: one test, then only enough
code to pass it, then the next test. Never all the tests, then the code — bulk
tests verify imagined behavior and go insensitive to real change.

Before the first test, name the **seams** you will test at: the public
interfaces where behavior is observable. A test that reaches inside a module
breaks on refactors that changed nothing.

## A good test

- Reads like a specification: "a repeated submit does not create a second record".
- Asserts on observable behavior through an interface, not on private state or
  call order.
- Its expected value comes from an independent source — a known-good literal, a
  worked example, the spec.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private
  methods, or asserts the mechanism instead of the outcome.
- **Tautological**: the expectation recomputes what the code computes
  (`expect(sum(a,b)).toBe(a+b)`), so it can never disagree with the code.
- **Horizontal slicing**: the whole test suite written up front. Work in
  tracer bullets instead.

## Rules

- Red first, and red for the right reason: run the test and read the failure.
- One seam, one test, one minimal implementation per cycle.
- Refactoring is not part of the loop; it belongs to review. Finish the slice
  green, then improve the shape.
- No speculative features: the next test decides what comes next.
