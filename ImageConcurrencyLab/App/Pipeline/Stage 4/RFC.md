# RFC: Stage 4 — Visible-First Scheduling

## Summary
Improve perceived scrolling responsiveness by prioritizing image loading for currently visible rows over off-screen prefetch requests.

## Motivation
During fast scrolling, rows that pass through the viewport are added to the loading queue. These requests may occupy the queue ahead of the rows that are actually visible, causing visible images to appear later than necessary.

## Proposal
Requests waiting for execution are divided into two priority classes:

- visible queue — requests for rows currently on screen
- prefetch queue — requests for rows outside the viewport

Implementation steps:

- Introduce `LabViewModel` that converts `onAppear` / `onDisappear` events into loading requests
- Maintain two waiting queues: visible and prefetch
- Implement queue migration when a row becomes visible
- Implement visible-first dequeue policy: when a loading slot becomes available, the scheduler serves the visible queue before the prefetch queue

### Out of scope
- in-flight metadata
- cancellation
- dynamic allocation
- decoder changes

## Load policy for a URL request

1. cached → return return cached value
2. in-flight → await existing task
3. waiting in prefetch → move to visible queue
4. absent everywhere → enqueue in visible queue
