#  About

SwiftUI performance lab that demonstrates how image-loading pipeline decisions affect responsiveness, task behavior, and UI invalidation under load

## Stage 1
Stage 1 uses row-local state and row-driven loading. Each row starts its own fetch when it appears. There is no shared cache, no in-flight deduplication, and no cancellation. As a result, repeated scrolling causes duplicate fetches and placeholder churn when rows are recreated.
