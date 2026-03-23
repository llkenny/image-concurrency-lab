# RFC: Stage 5 - Cancellation

## Summary
Improve delivery speed of currently visible rows by introducing cancellation of off-screen load.

## Motivation
During fast scrolling, visible rows must wait for previously started tasks to finish. 
Running work continues even when rows move offscreen, delaying visible content.

## Proposal
Add cancellation:

- cancel already started tasks when rows go offscreen
- cancel running tasks instead of waiting for completion
- free slot when cancelled task finishes

This stage:
- cancels in-flight tasks
- cancels queued visible work
- does not cancel cache hits
- does not reprioritize running tasks (they are cancelled instead)

Result: visible content appears faster during fast scrolling.

## Cancellation policy

If URL is in visible queue — move to prefetch queue  
If URL is running — cancel task  
If URL is already in prefetch queue — do nothing  

## Assumptions
Stage 5 must not change queue model.  
Only add cancellation.
