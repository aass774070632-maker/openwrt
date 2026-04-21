# ALemprator OTA Self-Hosted Weekly Execution Plan

This document is the execution-oriented version of the self-hosted OTA platform plan.
It is intended for project management, engineering execution, and delivery tracking.

It answers four operational questions:

1. what gets built each week
2. which role is responsible
3. what the measurable output is
4. how we decide that the phase is complete

## 1) Delivery Objective

Deliver a standalone OTA platform from scratch that can support the existing OpenWrt OTA client with:

1. device registration
2. firmware update lookup
3. device heartbeat/state tracking
4. firmware release publishing
5. minimal operator dashboard

Target outcome:

- a real API service
- a real database
- real firmware hosting
- a basic admin control plane
- successful end-to-end validation from OpenWrt router to OTA backend

## 2) Delivery Model

Recommended execution model:

1. weekly milestones
2. one technical owner per workstream
3. measurable acceptance criteria each week
4. no frontend polish before API reliability

Recommended total delivery horizon:

- 6 weeks for MVP
- 8 weeks if production hardening is included from the start

## 3) Team Structure

Minimum practical team:

1. Backend Engineer
Responsible for API, business logic, DB schema, validation, and release logic.

2. DevOps Engineer
Responsible for deployment, reverse proxy, database provisioning, TLS, storage, CI/CD, observability.

3. Frontend/Admin Engineer
Responsible for the operator dashboard used to manage devices and releases.

4. OpenWrt Integration Engineer
Responsible for router validation, firmware build flow, OTA client verification, and rollback testing.

5. Technical Lead
Responsible for architecture decisions, scope control, acceptance signoff, and production readiness review.

If the team is smaller, one person may cover multiple roles, but the responsibilities should remain explicit.

## 4) Workstreams

The project is divided into five workstreams.

### Workstream A: Backend Core

Includes:

1. NestJS service bootstrap
2. DB schema and migrations
3. OTA public endpoints
4. admin endpoints
5. validation and auth

### Workstream B: Infrastructure

Includes:

1. server provisioning
2. container runtime
3. reverse proxy and TLS
4. database
5. file storage
6. backups

### Workstream C: Firmware Distribution

Includes:

1. firmware artifact publishing
2. sha256 generation
3. direct binary serving
4. release metadata linkage

### Workstream D: Admin Panel

Includes:

1. login
2. release management UI
3. device fleet UI
4. release activation and rollout controls

### Workstream E: OpenWrt Validation

Includes:

1. registration tests
2. update lookup tests
3. download validation tests
4. sysupgrade dry-run tests
5. rollback/safety verification

## 5) Weekly Plan

## Week 1: Foundation And Architecture Lock

### Objective

Establish the technical foundation and freeze the core OTA protocol.

### Backend Engineer

Tasks:

1. create backend repository
2. initialize NestJS project
3. define environment config structure
4. define DTOs for `register`, `update`, `heartbeat`
5. define database schema draft

Outputs:

1. running NestJS service
2. project module structure
3. initial schema draft document

Acceptance:

1. app starts locally
2. environment config works
3. routes are reserved and documented

### DevOps Engineer

Tasks:

1. provision dev/staging server
2. install Docker and Docker Compose
3. prepare Nginx reverse proxy
4. prepare PostgreSQL instance
5. define domain/TLS strategy

Outputs:

1. reachable staging host
2. running Postgres instance
3. TLS termination design

Acceptance:

1. API container can be deployed to staging
2. DB is reachable from API service

### Frontend/Admin Engineer

Tasks:

1. decide admin UI framework
2. prepare admin UI repo or module
3. define pages needed for MVP

Outputs:

1. admin UI skeleton
2. route map for dashboard

Acceptance:

1. admin app boots locally

### OpenWrt Integration Engineer

Tasks:

1. document exact router request contract
2. capture sample register/update payloads
3. confirm firmware artifact naming strategy

Outputs:

1. verified client contract
2. real sample payload set

Acceptance:

1. backend team confirms contract with no ambiguity

### Week 1 Exit Criteria

1. protocol frozen
2. infra path chosen
3. repos bootstrapped
4. schema direction approved

## Week 2: Public OTA API MVP

### Objective

Build the minimum public OTA API used directly by routers.

### Backend Engineer

Tasks:

1. implement `POST /api/register`
2. implement `GET /api/update`
3. implement `POST /api/heartbeat`
4. add payload validation
5. add DB persistence for devices

Outputs:

1. working public OTA endpoints
2. device persistence in database

Acceptance:

1. `curl` tests pass for all three routes
2. endpoints return JSON only
3. no route returns HTML or redirect

### DevOps Engineer

Tasks:

1. create staging deployment config
2. add environment secrets handling
3. configure Nginx upstream and TLS

Outputs:

1. staging API reachable over HTTPS

Acceptance:

1. public routes work from outside the server

### OpenWrt Integration Engineer

Tasks:

1. point test router to staging endpoint
2. test `register`
3. test `check update`
4. test `heartbeat`

Outputs:

1. first end-to-end device registration

Acceptance:

1. router no longer returns `register_failed`

### Week 2 Exit Criteria

1. router can register
2. router can check update
3. router can post heartbeat

## Week 3: Release Management Core

### Objective

Enable operators to create and activate actual firmware releases.

### Backend Engineer

Tasks:

1. create `releases` table
2. create release creation API
3. create release listing API
4. create activate/deactivate API
5. implement model-based release lookup

Outputs:

1. release management backend
2. update lookup backed by real release records

Acceptance:

1. a release can be created for one model
2. `/api/update` returns that release correctly

### DevOps Engineer

Tasks:

1. prepare firmware storage path or bucket
2. configure static binary delivery
3. validate content-type and range support if needed

Outputs:

1. working HTTPS binary download path

Acceptance:

1. firmware URL returns binary file, not HTML
2. `sha256` can be matched against published metadata

### OpenWrt Integration Engineer

Tasks:

1. publish one test firmware release
2. test router update lookup against active release
3. test no-update path when versions match

Outputs:

1. first real firmware metadata roundtrip

Acceptance:

1. router shows `available` or `up_to_date` correctly

### Week 3 Exit Criteria

1. release publishing works
2. download URL works
3. `/api/update` serves real release metadata

## Week 4: Admin Panel MVP

### Objective

Give operators a usable interface to inspect fleet state and publish releases.

### Frontend/Admin Engineer

Tasks:

1. build login page
2. build devices list page
3. build releases list page
4. build release creation form
5. build activate/deactivate control

Outputs:

1. minimal operator dashboard

Acceptance:

1. operator can log in
2. operator can see devices
3. operator can create and activate a release

### Backend Engineer

Tasks:

1. implement admin auth
2. implement admin release endpoints
3. implement admin device list endpoints

Outputs:

1. admin APIs consumed by dashboard

Acceptance:

1. admin routes secured and functional

### Week 4 Exit Criteria

1. no direct DB edits are needed to run OTA
2. operator can publish release through UI or admin API

## Week 5: End-To-End OTA Validation

### Objective

Prove that the complete OTA flow works safely from router to server and back.

### OpenWrt Integration Engineer

Tasks:

1. test device register from clean state
2. test update lookup with active release
3. test firmware download
4. test `sysupgrade -T`
5. test actual update on non-critical device
6. test state after reboot

Outputs:

1. end-to-end validation report
2. identified defects list

Acceptance:

1. one device updates successfully through the full OTA flow
2. post-upgrade version is reported correctly

### Backend Engineer

Tasks:

1. fix edge cases found during OTA validation
2. improve error responses and observability

Outputs:

1. stabilized API behavior under real device traffic

### Week 5 Exit Criteria

1. OTA update works on real router hardware
2. no critical blocker remains in the core flow

## Week 6: Hardening And Production Readiness

### Objective

Make the platform safe enough for production rollout.

### Backend Engineer

Tasks:

1. add rate limiting
2. add request logging
3. add structured error handling
4. add audit/event logging

Outputs:

1. hardened API service

### DevOps Engineer

Tasks:

1. add backups for DB and storage
2. add monitoring and alerts
3. add service restart policy
4. document recovery path

Outputs:

1. production operations baseline

### Frontend/Admin Engineer

Tasks:

1. add release history visibility
2. add rollout percent controls
3. improve device detail page

Outputs:

1. more usable operator experience

### Technical Lead

Tasks:

1. run go-live checklist
2. review security posture
3. approve staged production rollout

Outputs:

1. production signoff decision

### Week 6 Exit Criteria

1. monitoring exists
2. backup exists
3. rollback path documented
4. platform approved for pilot rollout

## 6) Roles And Responsibility Matrix

### Backend Engineer

Owns:

1. DTOs
2. API endpoints
3. DB models
4. release logic
5. auth for admin APIs

### DevOps Engineer

Owns:

1. servers
2. Docker deployment
3. Nginx
4. TLS
5. PostgreSQL ops
6. storage and backups

### Frontend/Admin Engineer

Owns:

1. admin UI
2. device fleet pages
3. release management pages

### OpenWrt Integration Engineer

Owns:

1. router validation
2. firmware publishing verification
3. OTA flow testing
4. sysupgrade safety validation

### Technical Lead

Owns:

1. architecture signoff
2. scope control
3. weekly exit approval
4. go-live approval

## 7) Deliverables By Milestone

### Milestone A

By end of Week 2:

1. public OTA API operational
2. first successful router registration

### Milestone B

By end of Week 3:

1. release publishing functional
2. router receives real update metadata

### Milestone C

By end of Week 4:

1. admin panel MVP usable

### Milestone D

By end of Week 5:

1. full OTA update completed on real device

### Milestone E

By end of Week 6:

1. platform ready for pilot production rollout

## 8) Risks And Early Controls

### Risk 1: Firmware URLs return HTML instead of binary

Mitigation:

1. enforce direct binary storage path
2. add automated HEAD/GET validation before release activation

### Risk 2: Version comparison errors

Mitigation:

1. store sortable `version_code`
2. treat display version separately from comparison logic

### Risk 3: Unsafe rollout to all devices

Mitigation:

1. start with `rollout_percent = 10`
2. validate on pilot hardware first

### Risk 4: Insufficient observability

Mitigation:

1. add request logs in Week 6 at the latest
2. add device event logging before production rollout

### Risk 5: Scope expansion too early

Mitigation:

1. do not build multi-tenant/customer targeting in MVP
2. do not build advanced analytics before OTA flow works end to end

## 9) Definition Of Done For MVP

The MVP is done only when all of the following are true:

1. router can register successfully
2. router can check for updates successfully
3. backend can publish a release for a model
4. router can download firmware from returned URL
5. one device can complete an OTA update successfully
6. operator can inspect devices and releases from admin UI
7. HTTPS, backups, and minimum observability exist

## 10) Recommended Next Step

If execution starts now, Week 1 should begin with:

1. backend repository creation
2. staging server provisioning
3. API contract freeze
4. DB schema finalization

No UI work should block the public OTA API work.
The public device API must be delivered first.