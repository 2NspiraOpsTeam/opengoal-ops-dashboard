# DASHBOARD WIREFRAME v1 (Smart Funnel)

Owner: @NspiraAdamBot  
Date: 2026-02-28

## Page 1 — Executive Overview
- KPI Row:
  - Total Leads (period)
  - Total Conversions
  - Funnel Completion Rate
  - Revenue
  - Median Time-to-Convert
- Visuals:
  - Funnel (Awareness → Retention)
  - 30-day conversion trend
  - Channel contribution donut

## Page 2 — Funnel Diagnostics
- Stage-by-stage conversion table
- Leakage heatmap (stage x channel)
- Drop-off reasons (if metadata available)
- Stage dwell-time boxplot

## Page 3 — Channel Performance
- Channel scorecards:
  - Reach/Impressions
  - Engagement actions
  - Leads created
  - Conversions
  - Revenue
- Trend lines by channel
- Cost efficiency (if spend data exists)

## Page 4 — Campaign Analysis
- Campaign ranking table:
  - Conversion rate
  - RPL
  - Revenue
  - Time-to-convert
- Campaign funnel comparison chart
- Winner/loser movement week-over-week

## Page 5 — Retention / Expansion
- Repeat conversion rate
- Renewal/upsell count
- Cohort retention trend
- Referral contribution

## Smart Alerts (v1)
- Alert when stage conversion drops >20% vs 7-day baseline
- Alert when a channel has zero conversions for 3 consecutive days
- Alert when time-to-convert worsens >30% week-over-week

## Filters (global)
- Date range
- Channel
- Campaign
- Region
- Owner

## UX Notes
- Use traffic-light color semantics: green/yellow/red for health.
- Default to executive clarity; details on drill-down.
- Every chart must include definition tooltip for KPI transparency.
