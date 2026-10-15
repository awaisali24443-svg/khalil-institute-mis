# Khalil Institute Management System (Cloud)

Complete documentation — every module, every role, every feature, from A to Z.

**Live app:** https://awaisali24443-svg.github.io/khalil-institute-mis/cloud.html
**Backend:** Supabase (PostgreSQL with Row Level Security)
**Languages:** English / اردو (toggle in header)

---

## 1. Quick Start

### Test Logins

**Staff** (Staff tab — type just the username):

| Role | Username | Access |
|------|----------|--------|
| Admin | `admin` | All 16 tabs |
| Accountant | `accountant` | Dashboard, Fees, Accounts, Reports, SMS |
| Teacher | `teacher` | Dashboard, Attendance, Academics, Library |
| Reception | `reception` | Dashboard, Students, Letters, Library, Office, SMS |

> **Passwords:** Test accounts use simple passwords for demo only. **Change all passwords before going live** (Supabase → Authentication → Users → edit). Never publish real passwords.

**Student** (Student tab):

| Field | Value |
|-------|-------|
| CNIC | `3520212345671` (demo student) |
| Mobile | Use the student's registered mobile number |

Students log in with their **CNIC number** as username and **mobile number** as password. No separate accounts to create — when you add a student, their login is created automatically.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `1` – `9` | Jump to tab by number |
| `Ctrl+K` / `⌘+K` | Quick student search |
| `?` | Show shortcuts help |
| `Esc` | Close dialog / back to dashboard |

---

## 2. User Roles & Access

| Module | Admin | Accountant | Teacher | Reception | Student |
|--------|-------|------------|---------|-----------|---------|
| Dashboard | ✓ | ✓ | ✓ | ✓ | ✓ (own) |
| Students | ✓ | — | — | ✓ | — |
| Fees | ✓ | ✓ | — | — | ✓ (own) |
| HR | ✓ | — | — | — | — |
| Attendance | ✓ | — | ✓ | — | ✓ (own) |
| Accounts | ✓ | ✓ | — | — | — |
| Reports | ✓ | ✓ | — | — | — |
| Backup | ✓ | — | — | — | — |
| Settings | ✓ | — | — | — | — |
| Academics | ✓ | — | ✓ | — | ✓ (own) |
| Letters | ✓ | — | — | ✓ | — |
| Library | ✓ | — | ✓ | ✓ | — |
| Stock | ✓ | — | — | — | — |
| Office | ✓ | — | — | ✓ | — |
| Audit Log | ✓ | — | — | — | — |
| SMS | ✓ | ✓ | — | ✓ | — |

**Security:** Enforced by the database itself (Row Level Security). Even if someone bypasses the UI, they can only see/edit what their role allows. Students can only ever see their own records.

---

## 3. Modules — Complete Guide

### 3.1 Dashboard
Overview with 4 stat cards: Total Students, Collected This Month, Total Dues, Unpaid Challans. Recent Payments table (last 8). Quick action buttons: Quick Collect, Add Student, Mark Attendance, Add Expense.

### 3.2 Students
- **Student list:** All students with roll no, CNIC, phone, program, dues. Searchable.
- **Add Student:** 16-field form (name, father, gender, DOB, CNIC, phone, WhatsApp, email, district, address, qualification, board, marks, year, program, session, shift, etc.) + individual fee plan per student + photo upload.
- **Student Profile (360°):** Personal info, academic info, committed fee plan, challans & payments, **Payment History ledger** (every payment with date+time, receipt, amount, method), attendance summary, exam results, announcements.
- **Auto roll numbers:** Sequential per session (Spring/Fall).
- **Auto-login:** Saving a student creates their login (CNIC + phone).

### 3.3 Fees
- **Fee Structure:** Per-program fee heads (Admission, Monthly, Registration, Exam, Fine, Other). Add/edit/delete heads.
- **Generate Monthly Slips:** Creates challans for all active students in a session. Auto-queues SMS fee reminders.
- **Challans:** List with status (Paid / Partial / Unpaid / Overdue). Print challan. Record Payment.
- **Record Payment:** Amount, date, method (Cash/Bank/JazzCash/EasyPaisa), fee head, received by. Auto-updates challan paid amount and status. Generates receipt number. Prints receipt with timestamp.
- **Dues List:** All students with outstanding dues, sorted highest first.
- **Payment History:** Per-student ledger — total charged, total paid, remaining + every transaction with exact date/time.

### 3.4 HR
Employee list (teachers + staff). Add/edit employees: name, CNIC, phone, designation, salary, joining date, etc.

### 3.5 Attendance
- **Students tab:** Date picker, session filter, mark P/A/L per student, Mark All Present, Save. Saving auto-queues absence SMS for absent students.
- **Employees tab:** Same for staff.
- Students see a read-only view of their own attendance with percentage stats.

### 3.6 Accounts
- **Expenses:** Add expenses by category (Stock, Books, Newspaper, Utilities, Rent, Salaries, Other) with date and title.
- **Balance Sheet:** Income (fees collected) vs expenses = balance.
- **Vouchers:** Expense voucher list.

### 3.7 Reports
Monthly collection report: total collected, breakdown by payment method, payment list, defaulters list (students with dues), enrollment by program.

### 3.8 Backup
- **Download Backup:** Export all data as JSON file.
- **Restore:** Import from backup file.
- **Google Drive:** Backup to Google Drive (requires Client ID in Settings).

### 3.9 Settings
Institute name, change password, backup password, Google Client ID, load demo data, wipe all data (danger zone).

### 3.10 Academics
- **Subjects:** Per-program subjects with codes. Add/edit/delete.
- **Timetable:** Weekly grid by program + semester. Add periods (day, period, subject, teacher).
- **Examinations:** Define exams, select subjects, select students, generate roll number slips.
- **Marks Entry:** Enter obtained marks per student per subject.
- **Results:** Calculated results with positions, pass/fail. Print DMCs.

### 3.11 Letters
8 letter types: Notice, Meeting Notice, Seminar, Training Letter, Experience Certificate, Course Completion Certificate, Registration Letter, Fine Notice. Issue log tracks all issued letters.

### 3.12 Library
Book catalog (name, author, volume, serial, quantity, course). Issue/Receive tracking with dates.

### 3.13 Stock
Categories + items with quantity, price, purchase date. Track institute inventory.

### 3.14 Office
- **Hospital Training:** Partner hospitals, trainee assignments.
- **Visitors:** Visitor log (name, purpose, person to meet, time).
- **Events:** Institute events calendar.
- **Faculty Problems:** Staff issue tracking with resolve action.
- **CV Bank:** Job applicant CVs.
- **Registration:** Registration list from student database.
- **Compart List:** Students with compartment (from results).
- **Grace Marks:** Grace marks management.

### 3.15 Audit Log (Admin only)
Every change to students, fees, payments, expenses, marks, attendance, SMS — automatically recorded with who, when, what. Tamper-proof (users cannot edit/delete log entries). Last 200 entries shown.

### 3.16 SMS
- **Compose:** Select recipients (All Students / Defaulters / By Program / Custom numbers). Templates: Fee Reminder, Absence Alert, Exam Notice, General. Bilingual templates with auto-fill (name, dues, program, date). Live preview with character counter.
- **Outbox:** Pending messages queue. Delete or send via phone.
- **Sent Log:** History with timestamps and status.
- **Modem:** Connect USB GSM modem via Web Serial (Chrome/Edge). Phone Gateway for Android SMS gateway apps. Test SMS. Send queue.
- **Auto-triggers:** Fee reminders on challan generation. Absence alerts on attendance save.
- **Send via Phone:** Opens native SMS app with prefilled message (for testing/small batches).

---

## 4. Student Portal

Students log in with CNIC + mobile number. They see:
- **Their profile:** Personal info, program, fee plan
- **Fee status:** Challans, dues, **complete payment history** with timestamps
- **Attendance:** Their records with present/absent stats and percentage
- **Academics:** Their subjects, timetable, exam results

Students are **100% read-only**. They cannot edit, pay, mark attendance, or change anything. If something is wrong, they contact the admin.

Parents can use the child's CNIC + phone to view.

---

## 5. SMS Module — Detailed

### Setup Options

**Option A: USB GSM Modem (fully automatic)**
1. Buy USB GSM modem (~Rs 2,500–4,000)
2. Insert dedicated institute SIM with SMS bundle
3. Plug into office PC
4. Open MIS in Chrome → SMS → Modem → Connect Modem → select device
5. Queue processes automatically

**Option B: Android Phone Gateway (fully automatic)**
1. Install SMS gateway app on Android phone
2. Connect phone to same WiFi as PC
3. In MIS → SMS → Modem → Phone Gateway → enter the app's URL
4. Set delay (3–5 seconds recommended)
5. Send queue processes automatically

**Option C: Send via Phone (manual, for testing)**
1. In Outbox, tap "Send via Phone"
2. Native SMS app opens with message prefilled
3. Tap send

### Message Templates

Templates support placeholders: `{name}`, `{dues}`, `{program}`, `{date}`, `{exam}`

Urdu messages auto-detect and use UCS2 encoding (70 chars/SMS). English uses GSM encoding (160 chars/SMS).

### Costs
Standard SMS via own SIM: ~Rs 110–300/month on Jazz bundle (12,000 SMS). No per-message platform fees.

---

## 6. Database Setup

Run these SQL files **in order** in Supabase → SQL Editor → New Query → Run:

1. `cloud-migration.sql` — All 28 tables + Row Level Security policies
2. `cloud-roles.sql` — Assign roles to test users
3. `cloud-trigger-v2.sql` — Auto-provision student logins
4. `cloud-audit.sql` — Audit log + auto-timestamps
5. `cloud-sms.sql` — SMS outbox table

Each file is safe to re-run (uses IF NOT EXISTS / OR REPLACE).

### Tables (28)

students, employees, profiles, fee_heads, challans, payments, expenses, sessions, attendance, settings, subjects, timetable, exams, exam_students, marks, letters, hospitals, trainees, visitors, events, problems, cvs, books, book_issues, stock_cats, stock_items, audit_log, sms_outbox

---

## 7. Architecture Notes

- **Frontend:** Single HTML file, vanilla JS, no frameworks. Works on any device with a browser.
- **Backend:** Supabase (PostgreSQL). All data access via REST API with JWT auth.
- **Security:** Row Level Security on every table. Roles: admin, accountant, teacher, reception, student, pending.
- **Performance:** 30-second in-memory cache, request timeout + retry, silent token refresh, parallel data loading, single-pass dues calculation, hover prefetch, persistent shell (no full-page reloads).
- **Student auth:** Synthetic email `<cnic>@student.kin.local` with phone as password. Auto-created on student registration.

---

## 8. Troubleshooting

| Problem | Solution |
|---------|----------|
| Login button needs two clicks | Fixed — button now shows loading state |
| Blank page after login | Hard refresh (Ctrl+Shift+R). Check internet. |
| "Loading…" stuck | Check Supabase project isn't paused (open dashboard). |
| SMS modem not found | Use Chrome/Edge. Check USB connection. Try different baud rate. |
| Student can't log in | Verify CNIC is 13 digits, phone matches student record. |
| Data not showing | Check role permissions. Admin sees all. |
| Supabase paused | Free tier pauses after 7 idle days. Open the app to wake it. |

---

## 9. Going Live Checklist

- [ ] Run all 5 SQL files
- [ ] Create real staff logins (Supabase → Authentication → Add User)
- [ ] Set roles in app (Admin → Users, or via SQL)
- [ ] Wipe demo data (Settings → Danger Zone) or keep for trial
- [ ] Enter real students (their CNIC + phone becomes their login)
- [ ] Set up fee structure per program
- [ ] Generate first monthly challans
- [ ] Connect SMS modem or phone gateway
- [ ] Upgrade to Supabase Pro ($25/mo) for production

---

*Built for Khalil Institute, Shabqadar. Last updated: October 2026.*
