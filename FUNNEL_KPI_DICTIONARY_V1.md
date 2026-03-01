# FUNNEL KPI DICTIONARY v1

Owner: @NspiraAdamBot  
Date: 2026-02-28

## Funnel Stages
1. Awareness
2. Interest
3. Consideration
4. Conversion
5. Retention/Expansion

## Core KPIs

### 1) Stage Volume
- **Definition:** Distinct leads that entered a given stage in a selected period.
- **Formula:** `COUNT(DISTINCT lead_id)` from `fact_lead_stage` by `stage_id`.
- **Use:** Top-of-funnel and stage health.

### 2) Stage-to-Stage Conversion Rate
- **Definition:** % of leads that progressed from stage N to stage N+1.
- **Formula:** `leads_entered_stage_(N+1) / leads_entered_stage_N * 100`.
- **Use:** Identify stage friction and leakage.

### 3) Funnel Completion Rate
- **Definition:** % of Awareness-stage leads that reached Conversion.
- **Formula:** `converted_leads / awareness_leads * 100`.
- **Use:** End-to-end funnel effectiveness.

### 4) Leakage Rate by Stage
- **Definition:** % of leads that did not progress from a stage during period window.
- **Formula:** `1 - stage_to_stage_conversion_rate`.
- **Use:** Prioritize optimization.

### 5) Time-to-Convert (Median)
- **Definition:** Median elapsed time from first seen to first conversion event.
- **Formula:** `P50(conversion_at - first_seen_at)`.
- **Use:** Sales cycle speed.

### 6) Revenue per Lead (RPL)
- **Definition:** Revenue generated per lead entering funnel.
- **Formula:** `SUM(revenue) / awareness_leads`.
- **Use:** Monetization quality.

### 7) Channel Contribution to Conversion
- **Definition:** Share of total conversions attributed to each channel.
- **Formula:** `channel_conversions / total_conversions * 100`.
- **Use:** Budget and effort allocation.

### 8) Campaign Efficiency Index
- **Definition:** Weighted index combining conversion rate and RPL.
- **Formula (v1):** `0.6*(campaign_conversion_rate) + 0.4*(campaign_rpl_normalized)`.
- **Use:** Campaign ranking.

## Attribution Rule (v1)
- **Default:** Last-touch (conversion inherits latest touchpoint channel before conversion).
- **Roadmap:** Add first-touch + position-based model in v2.

## Data Quality Rules
- `stage_order` must be monotonic (no backward stage jumps without explicit status).
- Duplicate touchpoints with same `(lead_id, event_type, event_at)` should be deduplicated.
- Currency normalized to USD for dashboard rollups.

## Dashboard Minimum Tiles
1. Funnel chart (counts + conversion %)
2. Stage leakage heatmap
3. Channel performance leaderboard
4. Campaign comparison table
5. Conversion trend (daily/weekly)
6. Median time-to-convert trend
