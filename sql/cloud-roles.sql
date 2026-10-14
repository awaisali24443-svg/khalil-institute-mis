-- ============================================================
-- KIN Cloud — assign roles to the 5 test logins.
-- Run AFTER the test users are created (via sign-up).
-- Run in Supabase Dashboard -> SQL Editor -> New query -> Run.
-- ============================================================

-- confirm emails (in case confirmation is still on)
update auth.users set email_confirmed_at = coalesce(email_confirmed_at, now())
where email in ('kin.admin@test.local','kin.accountant@test.local','kin.teacher@test.local',
                'kin.reception@test.local','kin.student@test.local');

-- assign roles + link CNICs (teacher/student link to demo records)
update public.profiles p
set role = v.role, cnic = v.cnic
from (values
  ('kin.admin@test.local',      'admin',      null),
  ('kin.accountant@test.local', 'accountant', null),
  ('kin.teacher@test.local',    'teacher',    '3520166677782'),
  ('kin.reception@test.local',  'reception',  null),
  ('kin.student@test.local',    'student',    '3520212345671')
) as v(email, role, cnic)
join auth.users u on u.email = v.email
where p.id = u.id;

-- verify
select u.email, p.role, p.cnic
from auth.users u join public.profiles p on p.id = u.id
where u.email like 'kin.%@test.local'
order by u.email;
