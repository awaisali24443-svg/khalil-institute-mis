-- ============================================================
-- KIN Cloud — student auto-provisioning trigger (v2)
-- Run ONCE in Supabase Dashboard -> SQL Editor -> Run.
-- Students log in with CNIC (username) + phone number (password).
-- The app creates their login as <cnic>@student.kin.local behind
-- the scenes; this trigger detects that pattern and gives them
-- the student role linked to their CNIC automatically.
-- ============================================================

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  stu_cnic text;
begin
  if new.email ~ '^[0-9]{13}@student\.kin\.local$' then
    stu_cnic := split_part(new.email, '@', 1);
    insert into public.profiles (id, role, cnic)
    values (new.id, 'student', stu_cnic)
    on conflict (id) do update set role = 'student', cnic = excluded.cnic;
  else
    insert into public.profiles (id, role) values (new.id, 'pending')
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;

-- ============================================================
-- DONE. No changes needed for existing users.
-- ============================================================
