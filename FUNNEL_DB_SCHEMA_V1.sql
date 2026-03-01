-- FUNNEL_DB_SCHEMA_V1.sql
-- Version: v1
-- Owner: @NspiraAdamBot
-- Purpose: Relational schema for cross-channel marketing/sales funnel analytics

create extension if not exists pgcrypto;

-- ========== DIMENSIONS ==========
create table if not exists dim_channel (
  channel_id uuid primary key default gen_random_uuid(),
  channel_key text unique not null,        -- telegram, x, email, linkedin, website, etc.
  channel_name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists dim_campaign (
  campaign_id uuid primary key default gen_random_uuid(),
  campaign_key text unique not null,
  campaign_name text not null,
  owner text,
  start_date date,
  end_date date,
  budget numeric(12,2),
  created_at timestamptz not null default now()
);

create table if not exists dim_funnel_stage (
  stage_id smallint primary key,
  stage_key text unique not null,
  stage_name text not null,
  stage_order smallint not null unique,
  is_active boolean not null default true
);

insert into dim_funnel_stage(stage_id, stage_key, stage_name, stage_order)
values
  (1,'awareness','Awareness',1),
  (2,'interest','Interest',2),
  (3,'consideration','Consideration',3),
  (4,'conversion','Conversion',4),
  (5,'retention','Retention/Expansion',5)
on conflict (stage_id) do nothing;

-- ========== ENTITIES ==========
create table if not exists fact_lead (
  lead_id uuid primary key default gen_random_uuid(),
  external_ref text,                      -- crm/contact id if available
  first_seen_at timestamptz not null default now(),
  source_channel_id uuid references dim_channel(channel_id),
  source_campaign_id uuid references dim_campaign(campaign_id),
  country text,
  status text,
  created_at timestamptz not null default now()
);

create index if not exists idx_fact_lead_first_seen_at on fact_lead(first_seen_at);
create index if not exists idx_fact_lead_source_channel on fact_lead(source_channel_id);

create table if not exists fact_touchpoint (
  touchpoint_id uuid primary key default gen_random_uuid(),
  lead_id uuid not null references fact_lead(lead_id) on delete cascade,
  channel_id uuid not null references dim_channel(channel_id),
  campaign_id uuid references dim_campaign(campaign_id),
  event_type text not null,               -- impression, click, form_start, demo_booked, purchase
  event_at timestamptz not null,
  value numeric(12,2),                    -- monetary/event value when relevant
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_touchpoint_lead_eventat on fact_touchpoint(lead_id, event_at);
create index if not exists idx_touchpoint_channel_eventat on fact_touchpoint(channel_id, event_at);
create index if not exists idx_touchpoint_campaign_eventat on fact_touchpoint(campaign_id, event_at);

create table if not exists fact_lead_stage (
  lead_stage_id uuid primary key default gen_random_uuid(),
  lead_id uuid not null references fact_lead(lead_id) on delete cascade,
  stage_id smallint not null references dim_funnel_stage(stage_id),
  entered_at timestamptz not null,
  exited_at timestamptz,
  is_current boolean not null default true,
  channel_id uuid references dim_channel(channel_id),
  campaign_id uuid references dim_campaign(campaign_id),
  unique (lead_id, stage_id, entered_at)
);

create index if not exists idx_lead_stage_current on fact_lead_stage(is_current, stage_id);
create index if not exists idx_lead_stage_entered on fact_lead_stage(entered_at);

create table if not exists fact_conversion (
  conversion_id uuid primary key default gen_random_uuid(),
  lead_id uuid not null references fact_lead(lead_id) on delete cascade,
  conversion_type text not null,          -- booked_call, sale, closed_won, renewal
  conversion_at timestamptz not null,
  revenue numeric(12,2) not null default 0,
  currency text not null default 'USD',
  channel_id uuid references dim_channel(channel_id),
  campaign_id uuid references dim_campaign(campaign_id),
  metadata jsonb
);

create index if not exists idx_conversion_at on fact_conversion(conversion_at);
create index if not exists idx_conversion_channel on fact_conversion(channel_id);

-- ========== DAILY SNAPSHOT ==========
create table if not exists agg_funnel_daily (
  metric_date date not null,
  channel_id uuid references dim_channel(channel_id),
  campaign_id uuid references dim_campaign(campaign_id),
  stage_id smallint not null references dim_funnel_stage(stage_id),
  leads_in_stage integer not null default 0,
  entries integer not null default 0,
  exits integer not null default 0,
  primary key(metric_date, channel_id, campaign_id, stage_id)
);

create index if not exists idx_agg_funnel_daily_date on agg_funnel_daily(metric_date);

-- ========== VIEW: STAGE CONVERSION ==========
create or replace view vw_stage_conversion_daily as
with stage_counts as (
  select
    date_trunc('day', entered_at)::date as metric_date,
    channel_id,
    campaign_id,
    stage_id,
    count(distinct lead_id) as entered_leads
  from fact_lead_stage
  group by 1,2,3,4
)
select
  sc.metric_date,
  sc.channel_id,
  sc.campaign_id,
  sc.stage_id,
  sc.entered_leads,
  lead(sc.entered_leads) over (
    partition by sc.metric_date, sc.channel_id, sc.campaign_id
    order by sc.stage_id
  ) as next_stage_entered_leads,
  case
    when sc.entered_leads = 0 then null
    else round(
      (lead(sc.entered_leads) over (partition by sc.metric_date, sc.channel_id, sc.campaign_id order by sc.stage_id)::numeric
      / sc.entered_leads::numeric) * 100, 2)
  end as stage_to_next_conversion_pct
from stage_counts sc;
