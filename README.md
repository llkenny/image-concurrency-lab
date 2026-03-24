#  About

SwiftUI performance lab that demonstrates how image-loading pipeline decisions affect responsiveness, task behavior, and UI invalidation under load

## Stage 1
Stage 1 uses row-local state and row-driven loading. Each row starts its own fetch when it appears. There is no shared cache, no in-flight deduplication, and no cancellation. As a result, repeated scrolling causes duplicate fetches and placeholder churn when rows are recreated.

## Stage 2
Stage 2 adds a completed-data cache and in-flight deduplication. Repeated scrolling no longer causes duplicate fetches, and already fetched images are served from the cache.

## Stage 3
Stage 3 introduces a global concurrency limiter. New fetch work is bounded by a fixed limit, reducing task explosion and stabilizing CPU and I/O pressure. Cache hits and in-flight shared requests bypass the limiter.

## Stage 4
Stage 4 introduces visible-first admission.
Requests are split into visible and prefetch queues, and the loader always starts visible requests before prefetch requests when a slot becomes available.

## Stage 5
Stage 5 introduces cancellation of running offscreen work. When rows move offscreen, active requests are cancelled, which frees execution slots for currently visible rows. Queued requests are still retained and may later run as prefetch work.

## Stage 6
Stage 6 moves image decoding off the main thread.
Fetched data is decoded into Image on a background executor before delivery.
