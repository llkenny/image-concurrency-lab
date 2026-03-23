# RFC: Stage 6 - Background Decoding

## Summary
Move image decoding off the main thread.

## Motivation
Image decoding currently happens on the main thread when rows receive data.
This blocks scrolling and increases frame hitches.

## Proposal
Decode fetched data into Image on a background executor before delivery.

This stage:
- keeps fetch behavior unchanged
- moves decoding off MainActor
- caches decoded images
- preserves cancellation behavior

Result: smoother scrolling and reduced main-thread blocking.
