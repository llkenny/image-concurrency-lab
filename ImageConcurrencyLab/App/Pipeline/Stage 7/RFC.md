#  RFC: Stage 7 — Batched UI Updates

## Summary
Reduce UI invalidation frequency by batching image delivery instead of updating rows individually.

## Motivation
Current pipeline delivers images immediately when each request completes:

fetch → decode → resume waiter → row update

This leads to:
- many UI updates per frame
- view invalidation storm
- layout recalculation spikes
- potential frame drops during fast completion bursts

Especially visible when:
- cache hits
- fast decode
- multiple concurrent finishes (limit = 6)

## Proposal
Introduce delivery batching:
finish(url) → enqueue result
flush()     → deliver all results together

## Flush stragegy
flush every 16ms (1 frame)

Alternative:
- batch by count
- batch by queue empty
- flush on next runloop
- flush when idle

## Assumptions
- batching may delay image appearance slightly
- small latency increase is acceptable
- lab prioritizes smoothness over immediacy

