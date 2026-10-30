PRD — Cooperative Gig Services Platform
Oct 29, 2026 · @Peace
1. Overview
This platform lets households book verified electricians, plumbers, carpenters and cleaners through their local labour cooperative, with 85% of every booking going straight to the worker. It ships as a Flutter mobile app, a Node.js + SQLite backend and a cooperative admin dashboard (Problem Statement ID 26089).
Problem. Private gig platforms such as Urban Company take high commissions, give workers little control over pricing, and offer limited identity or trade verification that households can trust. Informal hiring has the opposite problem: no verification, no price transparency, no recourse.
Vision. A cooperative-backed marketplace where every worker is identity-, police- and trade-verified by their society, every booking shows a transparent fee split, and workers are matched hyper-locally (under 5 km).
Objectives
1.	Give workers a fair living wage: 85% of each booking paid directly to the worker.
2.	Fund worker welfare: 10% of each booking goes to a cooperative welfare and insurance pool.
3.	Build household trust through society-verified identity, police and certificate checks, shown as badges.
4.	Dispatch fast: surface available, verified workers within 5 km, ranked by distance, availability and workload.
5.	Run on low-cost infrastructure: deploy on cPanel with zero build steps and a single-file database.
Success metrics (proposed targets, to be confirmed)
Metric	Target	Why it matters
Worker share of booking value	85% (fixed by config)	Core fair-wage promise
Verified workers as share of listed workers	100%	Nothing unverified appears in the feed
Booking confirmation time (immediate slot)	Under 10 minutes median	Hyper-local dispatch works
Booking completion rate	80% or higher	Matching quality
Average worker rating	4.5 or higher	Service quality
Grievances resolved within 72 hours	90%	Cooperative accountability
Pilot size	1 society, 100 workers, 500 bookings	Proof of model before expansion
2. Users and personas
Three roles map directly to the role field at registration: customer, worker and cooperative_admin.
Persona	Who they are	Primary goals	Key needs
Customer (household)	Urban or semi-urban household needing a home service	Book a trustworthy tradesperson quickly at a known price	Verified badge, visible visit fee, distance, rating, clear price split, grievance route
Cooperative Worker	Electrician, plumber, carpenter or cleaner registered with a labour society	Steady local work at a fair wage, with welfare cover	Easy job accept ("काम स्वीकार करें"), Hindi UI, transparent earnings receipts, insurance status
Cooperative Admin	Staff of a labour society or federation	Keep the worker pool verified and the platform fair	Document review queue, pricing and welfare-percentage control, account search, diagnostics, grievance handling
Primary scenario. A household opens the app, picks the Cleaning category, chooses "Regular home cleaning", sees the verified workers within 5 km, reviews the fee split, and confirms an immediate or scheduled slot. The worker accepts in Hindi or English, completes the job, and receives 85% of the booking value.
3. Scope
V1 delivers the full booking loop for one cooperative society, with verification and admin tooling, and no online payment processing.
In scope
•	Flutter app for Customers and Workers with email/mobile + password auth and JWT sessions
•	Role selection at registration (Customer or Cooperative Worker); admin accounts created by seeding or by an existing admin
•	Society switcher, trade categories, hyper-local worker feed (under 5 km), filters
•	Booking flow with the 85/10/5 breakdown, immediate or scheduled slots, and booking history
•	Worker document upload (Aadhaar, police verification, trade certificate) and admin approval
•	Grievance filing and resolution tracking
•	English and Hindi localization, light and dark themes
•	Admin dashboard: verification queue, account management, services and pricing, diagnostics, storage manager
•	cPanel-ready Node.js backend with SQLite
Out of scope for V1
•	SMS OTP and third-party identity verification (login is direct password + JWT by design)
•	In-app payment gateway and automatic payouts; V1 records payout amounts but settles outside the app
•	Real-time chat, live GPS tracking and push notifications
•	iOS App Store release (Flutter keeps the option open)
•	Multi-society federation analytics
Assumptions
•	Payment is cash or UPI collected on site; the platform records the split per booking.
•	Worker location is a last-known position or society-registered locality, not continuous tracking.
•	Document files are stored on the server's disk and reviewed manually by cooperative admins.
•	One worker holds one primary trade category in V1.
4. Business model and fee split
Every booking total is split three ways, and the customer sees the split before confirming. Default ratios live in config.js and per-service overrides live in the services table (worker_cut, welfare_cut, platform_cut); the three cuts must always sum to 100%.
Component	Default share	Recipient	Purpose
Worker wage	85%	Worker, directly	Fair living wage
Welfare pool	10%	Cooperative	Insurance and welfare fund
Platform operations	5%	Platform	Hosting, support, maintenance
Worked example using the Figma service prices (INR)
Service	Price	Worker (85%)	Welfare (10%)	Platform (5%)
Regular home cleaning	₹399	₹339.15	₹39.90	₹19.95
Kitchen cleaning	₹699	₹594.15	₹69.90	₹34.95
Deep home cleaning	₹1,499	₹1,274.15	₹149.90	₹74.95
Rules
•	Amounts are computed server-side at booking time and stored on the booking (total_amount, worker_payout, welfare_payout), so later config changes never alter past bookings.
•	Rounding: compute worker and welfare shares to 2 decimals; the platform share is the remainder so the total always reconciles.
•	Only a cooperative admin can change ratios; every change is logged with who and when.
•	Welfare-pool eligibility is shown on the worker profile as welfare_active.
5. Functional requirements: mobile app
Priority key: P0 = must ship in V1, P1 = should ship, P2 = nice to have.
5.1 Splash and auth sheet
ID	Requirement	Priority
A-1	Minimal splash screen that hands off to a bottom-slide modal for Login or Registration	P0
A-2	Registration collects name, email, mobile, password and a role choice: Customer or Cooperative Worker	P0
A-3	Login accepts email or mobile plus password; JWT stored securely on device	P0
A-4	Workers who register land in a "pending society verification" state (amber) until approved	P0
A-5	English / Hindi language toggle available from the auth sheet	P1
5.2 Home screen: explore and dispatch
Matches Screen 1 in the Figma file.
ID	Requirement	Priority
H-1	Top bar with avatar, "Welcome back" greeting and name, and a notifications bell	P0
H-2	Cooperative society switcher pill (for example "Bhopal Central Co-op")	P0
H-3	Search field and quick trade category tiles (Cleaning, Electrical, Plumbing, AC Service in the design)	P0
H-4	Trust strip with three badges: 100% Verified, Fair Wage Split, Welfare Backed	P0
H-5	"Available Workers (5 km)" horizontal feed of worker micro-cards: distance, verified badge, rating, visit fee; "See All" opens the full list	P0
H-6	Empty and loading states for the worker feed (the design shows a loading placeholder bar)	P1
5.3 Category and matching screen
Matches Screen 2 (Cleaning Services) in the Figma file.
ID	Requirement	Priority
C-1	Header with back button, category title and a category icon button	P0
C-2	Hero banner with category tagline and aggregate rating	P1
C-3	Society and availability line (for example "Bhopal Central Co-op · Available today")	P0
C-4	"Choose your service" list showing title, description, price and duration; single-select with a check state	P0
C-5	Sticky footer with the selected service count, "onwards" price and a "Find a worker" button	P0
C-6	Filter sheet: radius (up to 5 km), trade sub-skill, availability	P0
C-7	Worker profile card showing cooperative registration number, verified badge, rating, jobs completed and insurance coverage status	P0
5.4 Booking and cooperative breakdown sheet
ID	Requirement	Priority
B-1	Price breakdown: worker wage, welfare pool contribution, platform fee, and total	P0
B-2	Slot selector: Immediate or Scheduled (date and time picker)	P0
B-3	Confirm booking creates a pending booking; worker can accept or decline	P0
B-4	Booking status moves through pending, accepted, completed, cancelled; customer can cancel before acceptance	P0
B-5	Customer can rate a worker after completion	P1
5.5 Profile and settings
ID	Requirement	Priority
P-1	Light / Dark mode toggle, persisted on device	P0
P-2	Cooperative ID and verification status, with a viewer for uploaded documents	P0
P-3	Booking history and earnings receipts showing the transparent split	P0
P-4	Society grievance desk: contact details and a form to file a grievance against a booking	P0
P-5	Language switch (English / Hindi)	P1
5.6 Worker-side flows
The source spec names the Cooperative Worker role but does not define worker screens, so these are proposed for V1.
•	Incoming job requests with a one-tap accept ("काम स्वीकार करें") and decline (P0)
•	Availability toggle (online / offline) (P0)
•	Document upload for Aadhaar, police verification and trade certificate, with status per document (P0)
•	Earnings receipts per completed job (P0)
6. Functional requirements: backend, dispatch and admin
6.1 Authentication
•	Register with name, email, mobile, password and role (customer, worker or cooperative_admin); email and mobile must each be unique.
•	Login with an identifier (email or mobile) plus password; the server validates and issues a JWT directly. No SMS OTP or third-party verification.
•	Passwords are stored only as salted hashes (password_hash); JWT secret and expiry come from config.js.
•	Role-based access control on every route: customers book, workers accept and upload documents, admins verify and configure.
6.2 Hyper-local dispatch
The worker feed returns only workers who are verified, available and within the requested radius (default and maximum 5 km), then ranks them.
1.	Hard filters: is_verified is true, availability is on, trade matches the requested category, distance is 5 km or less.
2.	Ranking inputs: distance (closer ranks higher), rating, and active workload (fewer open bookings ranks higher).
3.	Ties and fairness: when scores are close, rotate by least-recently-assigned so work spreads across the society's workers.
4.	Output per worker: distance, verified badge, rating, visit fee, cooperative registration number, welfare and insurance status.
The exact ranking weights are an open question (section 10); V1 can ship with distance first, then workload, then rating.
6.3 Booking and grievance logic
•	Booking states: pending, accepted, completed, cancelled; only valid transitions are allowed.
•	A worker cannot accept overlapping scheduled slots.
•	Completing a booking increments jobs_completed and updates rating_avg once rated.
•	A grievance is linked to a booking, filed by either party, and has status open or resolved; admins resolve it with a note.
6.4 Admin dashboard
Module	Capabilities
User and society management	Approve or reject pending worker documents (Aadhaar, certificate, police verification) with a reason; search and manage customer and worker accounts; set cooperative_id
Category and pricing	Add and edit trade services, flat visit prices and the welfare percentage; the three cuts must total 100%
Grievance desk	List, filter and resolve grievances
Backend health and diagnostics	Server uptime, memory footprint, SQLite file size, API latency check
Storage and documents	Inspect uploads in /storage, find orphaned files, view disk usage and manage allocation
7. UX and design system
The look is super-clean flat minimalism: no gradients and no glassmorphism blur. Trust is communicated with color (emerald for verified and fair-wage, amber for pending) rather than decoration.
Color tokens
Token	Light mode	Dark mode	Use
Primary	#0EA5E9	#38BDF8	Buttons, links, selected states
Background	#FFFFFF	#0F172A	Screen background
Surface (proposed)	#F8FAFC	#1E293B	Cards, sheets
Text primary	#0F172A	#F8FAFC	Body and headings
Verified / fair wage	#10B981	#10B981	Verified badges, wage indicators
Pending / warning	#F59E0B	#F59E0B	Pending society verification
Surface and secondary text tokens are not in the source spec and are proposed here to complete the light and dark mapping.
Navigation and interaction rules
•	Every screen, filter, category selector and detail drawer enters with a bottom slide, implemented as a PageRouteBuilder transition from offset (0.0, 1.0).
•	Micro-interactions are bottom-sheet driven (auth, filters, booking breakdown, document viewer).
•	Theme switch applies instantly and persists across launches.
•	Rupee amounts use INR formatting (₹) through the central config; all strings come from localized keys.
Figma review: what to align
The two Figma screens (Home and Cleaning Services) already cover the layout of sections 5.2 and 5.3. Differences from the written spec to resolve before build:
Item	Figma today	Spec says	Proposed action
Background	Soft mint-to-white gradient wash on both screens	Strictly no gradients	Replace with flat #FFFFFF / surface token
Primary color	Deep green for the "Find a worker" button and selected states	Sky blue #0EA5E9	Recolor to primary; keep emerald only for verified and fair-wage cues
Hero banner	Photo with dark overlay and tagline	Flat minimalist	Use a flat illustration or solid color block, or confirm photo is acceptable
Categories	Cleaning, Electrical, Plumbing, AC Service	Electricians, plumbers, carpenters, cleaners	Decide whether Carpentry replaces or joins AC Service
Bottom navigation	None shown	Bottom-sheet driven navigation	Confirm whether a tab bar is wanted; profile and history need an entry point
Dark mode	Not designed	Full dark token mapping	Design dark variants of both screens
Hindi	English only	English / Hindi toggle	Check text fit with Devanagari
Worker feed	Loading placeholder only	Card with distance, badge, rating, fee	Design the populated, empty and error states
8. Technical architecture
One Node.js + Express API, deployed on cPanel, serves both the Flutter app and the admin dashboard and owns the SQLite database and the document storage.
 
system architecture · 2 clients, 1 API, 2 stores
Both clients talk only to the API; the API alone reads and writes the database and the document storage.
Frontend (Flutter)
•	Folders: /lib/config, /lib/models, /lib/controllers, /lib/views, /lib/widgets, keeping UI, state and data separate.
•	lib/config/config.dart holds the API base URL, timeout thresholds, English / Hindi string keys and INR currency formatting.
Backend (Node.js + SQLite)
•	Plain JavaScript (CommonJS), npm, Express.js and SQLite3 or better-sqlite3; no TypeScript, Webpack or Babel.
•	Entry point server.js or app.js, runnable through cPanel's Passenger / Node.js selector.
•	config.js reads environment variables: port, JWT secret, storage paths and default fee-split ratios.
•	Single-file database.sqlite with migrations that run at startup, so a fresh deploy needs no setup.
•	/storage directory for worker IDs, skill certificates and trade badges.
Data model
Table	Fields from the spec	Notes
users	id, name, email, mobile, password_hash, role, cooperative_id, is_verified, created_at	Email and mobile unique
worker_profiles	id, user_id, trade_category, experience_years, aadhaar_doc, police_doc, certificate_doc, welfare_active, rating_avg, jobs_completed	Document columns hold storage file names
services	id, category_id, title, description, base_price, worker_cut, welfare_cut, platform_cut	Cuts must total 100%
bookings	id, customer_id, worker_id, service_id, status, booking_time, total_amount, worker_payout, welfare_payout, created_at	Status: pending, accepted, completed, cancelled
grievances	id, booking_id, filed_by_id, description, status	Status: open, resolved
Gaps in the spec, proposed additions
•	A cooperatives table (id, name, region), because users.cooperative_id and the society switcher need something to point to.
•	A categories table, because services.category_id references one.
•	Worker latitude, longitude and an availability flag, which the 5 km dispatch needs.
•	Per-document verification status and rejection reason, so workers can see what to fix.
•	A rating field on bookings, to feed rating_avg.
API outline (proposed)
Area	Endpoints
Auth	POST /api/auth/register, POST /api/auth/login, GET /api/me
Catalogue	GET /api/categories, GET /api/services?category=
Workers	GET /api/workers?lat=&lng=&radius=&category=, GET /api/workers/:id, POST /api/workers/documents (multipart), PATCH /api/workers/availability
Bookings	POST /api/bookings, GET /api/bookings, PATCH /api/bookings/:id/status
Grievances	POST /api/grievances, GET /api/grievances
Admin	GET /api/admin/verifications, PATCH /api/admin/verifications/:id, GET/POST/PUT /api/admin/services, GET /api/admin/users, GET /api/admin/health, GET /api/admin/storage
cPanel deployment checklist
•	Application root contains server.js, config.js, package.json; run npm install once in the cPanel Node.js selector.
•	Set environment variables for JWT secret, port and storage path; keep database.sqlite and /storage outside the public web root.
•	Confirm the host's Node.js version supports the chosen SQLite package before development starts.
9. Non-functional requirements
Area	Requirement
Security	Hashed passwords (bcrypt or equivalent); JWT with expiry; role checks on every route; rate limiting on login; input validation on all endpoints; HTTPS in production
Document privacy	Aadhaar, police and certificate files are private: not publicly served, accessible only to the owning worker and cooperative admins, with access logged
Data protection	Collect only what verification needs; document retention and deletion policy agreed with the cooperative; compliance with India's Digital Personal Data Protection Act to be confirmed with counsel
Performance	List and feed endpoints respond in under 500 ms at pilot scale (about 100 workers, 500 bookings); app cold start under 3 seconds on a mid-range Android phone
Reliability	Single-file SQLite with WAL mode, scheduled backup of database.sqlite and /storage; migrations run automatically and safely at startup
Deployability	No build step: plain CommonJS JavaScript, runnable by cPanel Passenger through server.js or app.js; configuration by environment variables
Localization	English and Hindi from launch; all strings through localization keys; INR formatting
Accessibility	Minimum 48 dp touch targets, WCAG AA contrast in both themes, scalable text, no meaning conveyed by color alone (badges also carry icon and label)
Compatibility	Android first; Flutter keeps iOS possible later
Observability	Diagnostics endpoint feeding the admin health page; structured server logs
10. Release plan, risks and open questions
Proposed phases (durations are estimates; no calendar dates were given)
1.	Foundation (weeks 1–2): finalize design tokens and Figma fixes; backend skeleton, config, SQLite migrations, auth and role middleware; Flutter project structure, theme and localization.
2.	Core booking loop (weeks 3–6): categories and services, worker feed with 5 km filtering, booking with fee split, worker accept flow, booking history.
3.	Trust and admin (weeks 7–9): document upload, admin verification queue, pricing management, grievance desk, diagnostics and storage manager.
4.	Polish and pilot prep (weeks 10–12): dark mode QA, Hindi QA, accessibility pass, cPanel deployment dry run, backup routine.
5.	Pilot: one society, onboarding of first workers, weekly review of the success metrics in section 1.
Risks
Risk	Impact	Mitigation
Low worker supply at launch	Empty feeds, poor first impression	Onboard workers through the society before opening to customers
Slow manual document verification	Workers stuck in pending	Admin queue with status and reason; target review time agreed with society
SQLite concurrency limits	Slow writes under load	WAL mode, short transactions; plan migration path to a server database if usage grows
Sensitive documents stored on server disk	Privacy breach	Private storage path, access control, logging, encryption at rest if host allows
cPanel Node.js hosting constraints	Deployment surprises	Early dry run; keep dependencies minimal and pure-JS where possible
Payments handled off-app	Split not enforced in practice	Record payout amounts per booking; society reconciles; add gateway in a later version
Fake or inaccurate location data	Wrong hyper-local matching	Society-registered locality as fallback; admin can correct
Open questions
•	☐ Is the visit fee shown in the app the full booking price, or only a visit charge with the service price quoted on site? The Figma shows service prices from ₹399 to ₹1,499.
•	☐ Is the 85/10/5 split fixed platform-wide, or can each society set its own?
•	☐ How is payment collected in V1: cash, UPI or both?
•	☐ What are the ranking weights for dispatch (distance, workload, rating)?
•	☐ Does Carpentry launch in V1 alongside AC Service?
•	☐ Are bottom tabs wanted, or is every destination reached only through bottom-slide sheets?
•	☐ Who creates the first cooperative admin accounts and the society records?
•	☐ Is the photo-style hero banner in Figma acceptable under the flat-minimalist rule?
