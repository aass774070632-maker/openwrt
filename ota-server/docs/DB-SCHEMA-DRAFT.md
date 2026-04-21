# OTA Server Database Schema Draft

This is the Week 1 schema draft for the self-hosted OTA platform.

## Core Tables

1. `devices`
2. `releases`
3. `release_files`
4. `device_events`
5. `admin_users`

## Purpose

- `devices`: current identity and status of routers
- `releases`: publishable firmware releases by model
- `release_files`: optional multiple artifacts per release
- `device_events`: audit trail and troubleshooting
- `admin_users`: operator access

## Current Status

This is a draft only.
No migration has been applied yet.
