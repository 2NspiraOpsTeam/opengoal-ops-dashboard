-- FUNNEL_SAMPLE_SEED_V1.sql
-- Minimal bootstrap seed for MVP preview

insert into dim_channel(channel_key, channel_name)
values ('telegram','Telegram'),('x','X'),('website','Website')
on conflict (channel_key) do nothing;

insert into dim_campaign(campaign_key, campaign_name, owner)
values ('ogs-launch','OGS Launch','team'),('ogs-webinar','OGS Webinar','team')
on conflict (campaign_key) do nothing;

-- Optional: seed entries can be loaded from CSV files in /data for full test runs.
