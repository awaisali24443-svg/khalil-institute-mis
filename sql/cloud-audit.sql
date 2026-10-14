-- ============================================================
-- KIN Cloud — audit log + updated_at triggers
-- Run ONCE in Supabase Dashboard -> SQL Editor -> Run.
-- 1) Creates audit_log table: every INSERT/UPDATE/DELETE on
--    sensitive tables is recorded automatically (who, when, what).
--    Only admins can read it. Users cannot tamper with it.
-- 2) Adds auto-updating updated_at on all data tables.
-- ============================================================

-- ---------- audit log table ----------
create table if not exists public.audit_log (
  id bigserial primary key,
  created_at timestamptz default now(),
  user_id uuid,
  user_role text,
  action text not null,
  table_name text not null,
  record_id text,
  details jsonb
);

alter table public.audit_log enable row level security;

drop policy if exists "audit admin read" on public.audit_log;
create policy "audit admin read" on public.audit_log for select
  using (public.my_role() = 'admin');
-- NOTE: no insert/update/delete policies on purpose.
-- Only the security-definer trigger below can write rows,
-- so app users cannot forge or erase audit entries.

create or replace function public.audit_trigger() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  rid text;
begin
  -- students/employees use 'key' as PK, all others use 'id'
  if TG_TABLE_NAME in ('students','employees') then
    if TG_OP = 'DELETE' then rid := old.key; else rid := new.key; end if;
  else
    if TG_OP = 'DELETE' then rid := old.id::text; else rid := new.id::text; end if;
  end if;
  insert into public.audit_log (user_id, user_role, action, table_name, record_id, details)
  values (
    auth.uid(),
    public.my_role(),
    TG_OP,
    TG_TABLE_NAME,
    rid,
    jsonb_build_object('old', to_jsonb(old), 'new', to_jsonb(new))
  );
  return coalesce(new, old);
end;
$$;

-- ---------- attach to sensitive tables ----------
do $$
declare
  t text;
begin
  for t in select unnest(array[
    'students','employees','fee_heads','challans','payments',
    'expenses','marks','attendance','subjects','exams'
  ]) loop
    execute format('drop trigger if exists trg_audit on public.%I', t);
    execute format(
      'create trigger trg_audit after insert or update or delete on public.%I
       for each row execute function public.audit_trigger()', t);
  end loop;
end;
$$;

-- ---------- updated_at auto-touch ----------
create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  for t in select unnest(array[
    'students','employees','fee_heads','challans','payments','expenses',
    'sessions','attendance','settings','subjects','timetable','exams',
    'exam_students','marks','letters','hospitals','trainees','visitors',
    'events','problems','cvs','books','book_issues','stock_cats','stock_items'
  ]) loop
    execute format('drop trigger if exists trg_touch on public.%I', t);
    execute format(
      'create trigger trg_touch before update on public.%I
       for each row execute function public.touch_updated_at()', t);
  end loop;
end;
$$;

-- ============================================================
-- DONE. Verify: select * from public.audit_log limit 5;
-- ============================================================
