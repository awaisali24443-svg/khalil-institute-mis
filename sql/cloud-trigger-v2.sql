-- ============================================================
-- KIN Cloud — student auto-provisioning trigger (v3)
-- Run ONCE in Supabase Dashboard -> SQL Editor -> Run.
-- Students log in with CNIC (username) + phone number (password).
-- The app creates their login as <cnic>@student.kin.local behind
-- the scenes; this trigger detects that pattern and gives them
-- the student role linked to their CNIC automatically.
--
-- v3 fixes:
--   1. Actually ATTACHES the trigger to auth.users (was missing).
--   2. Verifies the CNIC exists in public.students before granting
--      the student role. Unknown CNICs get 'pending' (no access).
-- ============================================================

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  stu_cnic text;
  stu_exists boolean;
begin
  if new.email ~ '^[0-9]{13}@student\.kin\.local$' then
    stu_cnic := split_part(new.email, '@', 1);
    -- verify this CNIC is a real student in the database
    select exists(
      select 1 from public.students
      where key = stu_cnic
    ) into stu_exists;
    if stu_exists then
      insert into public.profiles (id, role, cnic)
      values (new.id, 'student', stu_cnic)
      on conflict (id) do update set role = 'student', cnic = excluded.cnic;
    else
      -- unknown CNIC: lock out until admin reviews
      insert into public.profiles (id, role, cnic)
      values (new.id, 'pending', stu_cnic)
      on conflict (id) do update set role = 'pending', cnic = excluded.cnic;
    end if;
  else
    insert into public.profiles (id, role) values (new.id, 'pending')
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;

-- attach the trigger to auth.users (idempotent)
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- DONE. Verify: sign up with a fake CNIC -> profile role = 'pending'.
-- ============================================================
