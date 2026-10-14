-- ============================================================
-- KIN Cloud — SMS outbox table
-- Run ONCE in Supabase Dashboard -> SQL Editor -> Run.
-- Stores outgoing SMS: compose in MIS -> sent via USB modem
-- (Web Serial) from the office PC -> delivery logged here.
-- ============================================================

create table if not exists public.sms_outbox (
  id bigserial primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);
-- data: {to, message, status, created_at, sent_at, error, by, template}

alter table public.sms_outbox enable row level security;

drop policy if exists "sms read" on public.sms_outbox;
create policy "sms read" on public.sms_outbox for select
  using (public.my_role() in ('admin','accountant','reception'));

drop policy if exists "sms write" on public.sms_outbox;
create policy "sms write" on public.sms_outbox for all
  using (public.my_role() in ('admin','accountant','reception'))
  with check (public.my_role() in ('admin','accountant','reception'));

-- audit trail for SMS
do $$
declare t text := 'sms_outbox';
begin
  execute format('drop trigger if exists trg_audit on public.%I', t);
  execute format('create trigger trg_audit after insert or update or delete on public.%I
    for each row execute function public.audit_trigger()', t);
  execute format('drop trigger if exists trg_touch on public.%I', t);
  execute format('create trigger trg_touch before update on public.%I
    for each row execute function public.touch_updated_at()', t);
end $$;

-- ============================================================
-- DONE. Verify: select count(*) from public.sms_outbox;
-- ============================================================
