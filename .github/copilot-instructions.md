# AI Coding Agent Instructions for BOINC Web Dashboard

## Project Overview
A Rails 7 web application that monitors BOINC distributed computing clients across a LAN. The app provides a real-time dashboard showing computers and their computing tasks by querying BOINC GUI RPC endpoints.

## Core Architecture

### Three-Tier Data Flow
1. **BOINC Clients** (remote computers running BOINC, e.g., 192.168.5.78) expose GUI RPC on port 31416
2. **Scheduled Background Jobs** (`UpdateComputersJob`, `UpdateTasksJob`) periodically fetch XML-RPC data via `BoincRpcClient`
3. **Rails Models + ActionCable** persist data to PostgreSQL and broadcast updates to connected browsers in real-time

### Key Services & Components

- **`BoincRpcClient`** (`app/services/boinc_rpc_client.rb`): Low-level XML-RPC socket wrapper that queries BOINC hosts. Returns parsed host info and task results. Handles IP-to-hostname resolution for WSL/Docker virtual IPs (see hardcoded IP mappings in `get_host_info`).

- **Jobs** (`app/jobs/`): Run via SolidQueue (configured in `config/application.rb`). 
  - `UpdateComputersJob`: Runs every minute, calls `get_host_info()` for each computer
  - `UpdateTasksJob`: Runs every 10 seconds, fetches tasks via `get_results()` and cleans stale records
  - Scheduled in `config/recurring.yml`

- **Models** (`app/models/`):
  - `Computer`: Single row per BOINC host with attributes fetched from RPC (CPU count, memory, OS, etc.)
  - `Task`: Computed work units; uses ActionCable callbacks to broadcast updates (create/update/destroy) over WebSocket channel "tasks"

- **Real-Time Updates**: Models use `broadcast_*` callbacks (`after_create_commit`, `after_update_commit`, `after_destroy_commit`) via ActionCable to push DOM changes to browsers without polling.

## Development Workflow

### Starting the Application
```bash
bin/dev  # Runs Procfile.dev: Rails server + Tailwind CSS watcher
```
Uses Foreman to run both `web` and `css` processes on ports 3000 and for Tailwind watch.

### Database
- Adapter: PostgreSQL (not SQLite)
- Migrations: `db/migrate/`
- `bin/rails db:create`, `db/reset`, `db/migrate` as standard

### Testing
- Test files in `test/` directory following Rails convention
- `bin/rails test` to run
- Fixtures for `computers` and `tasks` in `test/fixtures/`

### Job Queue Management
- Mission Control UI: `http://localhost:3000/jobs` (via SolidQueue::Engine mount in routes)
- Inspect running/failed jobs, retry failed tasks

## Conventions & Patterns

### Naming Patterns
- Computer names are case-insensitive, normalized to lowercase for lookups: `Computer.where("lower(name) = ?", params[:computer].downcase)`
- IP addresses are primary identifiers; some are remapped (e.g., 192.168.5.79 → 192.168.5.78) due to WSL adapter issues

### Frontend Tech Stack
- **CSS Framework**: Tailwind CSS (Rails 7 default integration via `tailwindcss-rails`)
- **JavaScript**: Stimulus (Hotwire) for minimal interactivity; Turbo for turbo-charged links
- **View Structure**: ERB templates in `app/views/` with nested folders per resource (e.g., `tasks/`, `computers/`)
- **Real-Time DOM**: ActionCable broadcasts drive Turbo Stream responses; no manual fetch/AJAX patterns

### Error Handling in Jobs
Jobs rescue errors, log them with full backtrace to Rails logger, then re-raise to mark as failed execution. Example from `UpdateTasksJob`:
```ruby
rescue StandardError => e
  Rails.logger.error "--- An ERROR occurred in UpdateTasksJob: #{e.message} ---"
  Rails.logger.error e.backtrace.join("\n")
  raise e
end
```

## Important File Locations

| Purpose | Path |
| --- | --- |
| BOINC RPC Client | [app/services/boinc_rpc_client.rb](app/services/boinc_rpc_client.rb) |
| Background Jobs | [app/jobs/](app/jobs/) |
| Data Models | [app/models/](app/models/) |
| Job Scheduling | [config/recurring.yml](config/recurring.yml) |
| Routes & Mission Control | [config/routes.rb](config/routes.rb) |
| Main Dashboard | [app/controllers/main_controller.rb](app/controllers/main_controller.rb) |
| Real-Time Channels | [app/channels/](app/channels/) |
| Database Schema | [db/schema.rb](db/schema.rb) |

## Quick Reference: Adding a New Feature

1. **New data field from BOINC**: Add column to Computer/Task migration, update `BoincRpcClient.get_host_info()` or `get_results()` XML parsing, update model
2. **New dashboard view**: Add route in [config/routes.rb](config/routes.rb), create controller action in [app/controllers/main_controller.rb](app/controllers/main_controller.rb) or new controller, create ERB template
3. **Real-time updates**: Add `broadcast_*` callbacks to model; changes auto-push via ActionCable
4. **Recurring job**: Add entry to [config/recurring.yml](config/recurring.yml) with cron schedule; create job class in [app/jobs/](app/jobs/)

## External Dependencies
- Ruby 3.2.6
- Rails 7.2.2
- PostgreSQL database
- Redis (for ActionCable in production)
- Remote BOINC hosts with GUI RPC accessible on LAN

## Rails 8 Migration Guide

### Key Changes & Dependencies
- **Ruby version**: Rails 8 requires Ruby 3.1+ (current 3.2.6 is compatible)
- **Gemfile updates**:
  - `gem "rails", "~> 8.0"` (from 7.2.2)
  - `gem "tailwindcss-rails"` may need version bump
  - `gem "solid-queue"` may have breaking changes—verify queue configuration
  - Check all gems in `Gemfile` for Rails 8 compatibility via `bundle update`

### Areas Requiring Changes

1. **ActionCable & Real-Time Broadcasts**:
   - Rails 8 changes Turbo Stream broadcast API slightly
   - `broadcast_*` methods in `Task` model should still work but test thoroughly
   - Verify `after_create_commit`, `after_update_commit`, `after_destroy_commit` behavior

2. **Configuration**:
   - `config/application.rb`: Update `config.load_defaults` from 7.0 to 8.0
   - Review deprecation warnings from Rails 7.2.2 (run `rails about` for warnings)
   - Job adapter: `config.active_job.queue_adapter = :solid_queue` needs verification with SolidQueue Rails 8 version

3. **Database**:
   - PostgreSQL adapter updates may require testing
   - Run migrations fresh: `bin/rails db:migrate` to ensure compatibility

4. **Views & Stimulus**:
   - Hotwire (Turbo + Stimulus) should be largely compatible
   - Test JavaScript controllers in `app/javascript/controllers/` for any behavior changes

5. **Background Jobs**:
   - SolidQueue integration may have API changes
   - Retest `UpdateComputersJob` and `UpdateTasksJob` in `config/recurring.yml` after upgrade

### Upgrade Steps
1. Create a feature branch: `git checkout -b upgrade/rails-8`
2. Update Gemfile: `bundle update rails`
3. Run `bin/rails app:update` (Rails provides an interactive upgrade guide)
4. Update `config/load_defaults` to 8.0
5. Run `bin/rails db:migrate` to test database compatibility
6. Run `bin/rails test` to verify all tests pass
7. Start app with `bin/dev` and manually test:
   - Computer updates via background jobs
   - Real-time Task broadcasts on the dashboard
   - Job queue in Mission Control UI (`http://localhost:3000/jobs`)
8. Review any deprecation warnings in Rails logs
