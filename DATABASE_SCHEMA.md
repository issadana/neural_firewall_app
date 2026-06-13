# Neural Firewall Backend - Database Schema

## Overview
This document outlines the complete database schema for the Neural Firewall Backend system. The database manages user authentication, threat detection, access control lists, and machine learning model versions.

---

## Tables

### 1. users
Core user account management table.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Unique user identifier |
| email | String(255) | Unique, Not Null | User email address |
| password | String(255) | Not Null | Hashed password |
| is_admin | Boolean | Default: False | Admin privilege flag |
| created_at | DateTime | Default: UTC Now | Account creation timestamp |

**Relationships:**
- (1) ↔ (many) refresh_tokens
- (1) ↔ (many) blacklist_entries
- (1) ↔ (many) acl_entries
- (1) ↔ (many) unknown_events
- (1) ↔ (1) user_settings
- (1) ↔ (many) model_versions

---

### 2. refresh_tokens
JWT refresh token management for session persistence.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Token record identifier |
| jti | String(36) | Unique, Not Null | JWT Token ID (claim identifier) |
| user_id | Integer | FK → users.id | Associated user |
| revoked | Boolean | Default: False | Token revocation status |
| created_at | DateTime | Default: UTC Now | Token creation timestamp |

**Purpose:** Tracks JWT tokens for revocation and session management.

---

### 3. blacklist_entries
IP addresses flagged as potential threats.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Entry identifier |
| user_id | Integer | FK → users.id | User who owns this entry |
| ip | String(45) | Not Null | IP address (IPv4 or IPv6) |
| reason | String(20) | Default: "manual" | Reason for blacklisting (e.g., "brute_force", "dos", "manual") |
| bf_score | Float | Nullable | Brute force threat score (0-1) |
| dos_score | Float | Nullable | DoS threat score (0-1) |
| notes | String(255) | Nullable | Admin notes |
| added_at | DateTime | Default: UTC Now | Entry creation timestamp |

**Unique Constraint:** (user_id, ip) - Prevents duplicate IPs per user

---

### 4. acl_entries
Access Control List - whitelisted IP addresses.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Entry identifier |
| user_id | Integer | FK → users.id | User who owns this entry |
| ip | String(45) | Not Null | Whitelisted IP address |
| notes | String(255) | Nullable | Notes about this IP |
| added_at | DateTime | Default: UTC Now | Entry creation timestamp |

**Unique Constraint:** (user_id, ip) - Prevents duplicate IPs per user

---

### 5. unknown_events
Network events flagged for review or training.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Event identifier |
| user_id | Integer | FK → users.id | User detecting the event |
| src_ip | String(45) | Nullable | Source IP address |
| src_port | Integer | Nullable | Source port number |
| dst_port | Integer | Nullable | Destination port number |
| protocol | Integer | Nullable | Protocol number (TCP=6, UDP=17, etc.) |
| size_bytes | Integer | Nullable | Packet size in bytes |
| flow_iat_mean | Float | Nullable | Inter-arrival time mean (ms) |
| tot_fwd_pkts | Integer | Nullable | Total forward packets |
| pkt_size_avg | Float | Nullable | Average packet size |
| flow_duration | Float | Nullable | Flow duration (seconds) |
| bf_score | Float | Nullable | Brute force threat score |
| dos_score | Float | Nullable | DoS threat score |
| status | String(20) | Default: "pending" | Event status (pending, reviewed, classified) |
| label | String(20) | Nullable | Classification label |
| created_at | DateTime | Default: UTC Now | Event detection timestamp |
| reviewed_at | DateTime | Nullable | Review completion timestamp |

**Relationships:**
- (1) ↔ (1) training_samples

---

### 6. training_samples
Labeled samples for ML model training.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Sample identifier |
| event_id | Integer | FK → unknown_events.id, Unique | Associated event |
| label | String(20) | Not Null | Classification label |
| protocol | Integer | Nullable | Protocol number |
| flow_iat_mean | Float | Nullable | Inter-arrival time mean |
| tot_fwd_pkts | Integer | Nullable | Total forward packets |
| pkt_size_avg | Float | Nullable | Average packet size |
| flow_duration | Float | Nullable | Flow duration |
| created_at | DateTime | Default: UTC Now | Sample creation timestamp |

**Purpose:** Contains labeled data used for training ML models to detect threats.

---

### 7. user_settings
User-specific configuration preferences.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Settings record identifier |
| user_id | Integer | FK → users.id, Unique | Associated user |
| block_threshold | Float | Default: 0.20 | Score threshold for blocking (0-1) |
| warn_threshold | Float | Default: 0.10 | Score threshold for warning (0-1) |
| flood_detection | Boolean | Default: True | Enable generic flood detection |
| syn_flood_detection | Boolean | Default: True | Enable SYN flood detection |
| flood_pkt_per_sec | Integer | Default: 1000 | Packets per second threshold for floods |
| syn_flood_per_sec | Integer | Default: 100 | SYN packets per second threshold |
| bf_model_enabled | Boolean | Default: True | Enable brute force ML model |
| dos_model_enabled | Boolean | Default: True | Enable DoS ML model |
| max_log_entries | Integer | Default: 200 | Maximum event logs to retain |

**Purpose:** Stores personalized detection thresholds and feature toggles for each user.

---

### 8. model_versions
Deployed and archived ML models.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | Integer | Primary Key | Model version identifier |
| user_id | Integer | FK → users.id | User who owns the model |
| name | String(100) | Not Null | Model name (e.g., "BF_v2.1", "DoS_v3.0") |
| filename | String(255) | Not Null | Storage filename/path |
| accuracy | Float | Nullable | Model accuracy score (0-1) |
| samples | Integer | Nullable | Training samples used |
| is_active | Boolean | Default: False | Whether model is in production |
| deployed_at | DateTime | Default: UTC Now | Deployment timestamp |

**Purpose:** Tracks ML model versions, allowing rollback and version management.

---

## Entity Relationships

```
users (1) ─────── (many) refresh_tokens
users (1) ─────── (many) blacklist_entries
users (1) ─────── (many) acl_entries
users (1) ─────── (many) unknown_events ─────── (1) training_samples
users (1) ─────── (1) user_settings
users (1) ─────── (many) model_versions
```

---

## Frontend Planning Notes

### Authentication Flow
- Users authenticate with email/password
- JWT tokens are issued and stored in `refresh_tokens` table
- Tokens can be revoked via the `revoked` flag

### Threat Management
- **Blacklist:** Automatically or manually blocked IPs with threat scores
- **ACL:** Whitelisted IPs that always pass through
- **Unknown Events:** Logged suspicious activity awaiting review
- **Training Samples:** Events labeled for model training

### Machine Learning
- Models are versioned in `model_versions` table
- Only one model per type should have `is_active = True`
- Training data comes from labeled `training_samples`

### User Configuration
- Each user has personalized thresholds and feature toggles
- Settings affect how events are scored and displayed
- Defaults ensure system works out-of-the-box

---

## Data Types Reference

| Type | Range/Size | Use Case |
|------|-----------|----------|
| Integer | -2^31 to 2^31-1 | IDs, counters, ports, protocols |
| Float | IEEE 754 | Threat scores, averages, durations |
| String(N) | Up to N characters | Text data, IPs, emails |
| Boolean | True/False | Flags, toggles |
| DateTime | Timestamp | Event tracking, auditing |

---

## Indexing Strategy (Recommended)

For optimal frontend performance, ensure these indexes exist:
- `users.email` (Unique) - Fast login lookups
- `blacklist_entries.ip` - Quick IP threat checks
- `acl_entries.ip` - Quick whitelist lookups
- `unknown_events.user_id` - User event listing
- `unknown_events.created_at` - Time-based queries
- `unknown_events.status` - Filter by status
- `training_samples.created_at` - Recent samples

---

**Last Updated:** 2026-06-06
**Version:** 1.0
