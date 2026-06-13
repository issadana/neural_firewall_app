# Neural Firewall — Full Existing DB Implementation Edits Plan

> **Last Updated:** 2026-06-07  
> **Covers:** Backend DB + API 
---

## Table of Contents

1. [Database Changes](#1-database-changes)
2. [Backend API Endpoints](#2-backend-api-endpoints)

---

## 1. Database Changes

### 1.1 Modify `users` Table

Add one column:

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `username` | String(100) | Not Null, Unique | Display name |

Updated `POST /auth/register` and `PUT /users/me` must handle this field.


---

### 1.2 New Table: `hardware_metrics`

Periodic device health snapshots sent every 2 minutes from the app.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | Integer | Primary Key | |
| `user_id` | Integer | FK → users.id | |
| `cpu_usage` | Float | Not Null | CPU usage % (0–100) |
| `ram_used_mb` | Integer | Not Null | Used RAM in MB |
| `ram_total_mb` | Integer | Not Null | Total RAM in MB |
| `battery_level` | Float | Nullable | Battery % (0–100) |
| `recorded_at` | DateTime | Default: UTC Now | When snapshot was taken |

**Indexes:** `user_id`, `recorded_at`

---

### 1.3 New Table: `firewall_logs`

One row per packet that has been evaluated by the AI model pipeline.

**Network identifiers**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | Integer | Primary Key, Auto Increment | |
| `user_id` | Integer | FK → users.id, Not Null | |
| `created_at` | DateTime | Default: UTC Now | When log entry was created |
| `src_ip` | String(45) | Nullable | Source IP address |
| `src_port` | Integer | Nullable | Source port |
| `dst_ip` | String(45) | Nullable | Destination IP address |
| `dst_port` | Integer | Nullable | Destination port |
| `protocol` | Integer | Nullable | TCP=6, UDP=17, ICMP=1 |

**Packet / flow features (AI model inputs)**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `size_bytes` | Float | Default: 0 | Packet size in bytes |
| `flow_duration` | Float | Default: 0 | Flow duration in seconds |
| `flow_iat_mean` | Float | Default: 0 | Inter-arrival time mean (ms) |
| `iat_std` | Float | Default: 0 | Inter-arrival time standard deviation |
| `tot_fwd_pkts` | Float | Default: 0 | Total forward packets in flow |
| `bwd_pkts` | Float | Default: 0 | Total backward packets in flow |
| `fwd_max` | Float | Default: 0 | Max forward packet length |
| `fwd_rate` | Float | Default: 0 | Forward packet rate |
| `fwd_mean` | Float | Default: 0 | Mean forward packet length |
| `idle_mean` | Float | Default: 0 | Mean idle time between bursts |
| `pkt_size_avg` | Float | Default: 0 | Average packet size |

**AI model outputs**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `prob_brute` | Float | Default: 0 | Brute-force attack probability (0–1) |
| `prob_dos` | Float | Default: 0 | DoS attack probability (0–1) |
| `prob_adv_dos` | Float | Default: 0 | Advanced DoS probability (0–1) |
| `prob_loic` | Float | Default: 0 | LOIC flood probability (0–1) |
| `prob_hoic` | Float | Default: 0 | HOIC flood probability (0–1) |
| `selected_model` | String(100) | Nullable | Name of the model with highest score |
| `selected_score` | Float | Not Null | Winning model's probability score (0–1) |

**Classification result**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `threat_type` | String(50) | Nullable | `brute_force` / `dos` / `normal` / etc. |
| `action` | String(20) | Not Null | `blocked` / `warned` / `allowed` |

**App / service context**

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `service_name` | String(100) | Nullable | Destination service from DNS: `YouTube`, `WhatsApp` |
| `app_name` | String(100) | Nullable | Source app on device: `Chrome`, `WhatsApp`, `System` |
| `app_package` | String(200) | Nullable | Package name: `com.android.chrome` |
| `is_system` | Boolean | Default: False | True if Android UID < 10000 |

**Indexes:** `user_id`, `created_at`, `action`, `service_name`, `app_name`

**SQL:**

```sql
CREATE TABLE `firewall_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),

  -- Network identifiers
  `src_ip` varchar(45) DEFAULT NULL,
  `src_port` int(11) DEFAULT NULL,
  `dst_ip` varchar(45) DEFAULT NULL,
  `dst_port` int(11) DEFAULT NULL,
  `protocol` int(11) DEFAULT NULL,

  -- Packet / flow features (AI model inputs)
  `size_bytes` float DEFAULT 0,
  `flow_duration` float DEFAULT 0,
  `flow_iat_mean` float DEFAULT 0,
  `iat_std` float DEFAULT 0,
  `tot_fwd_pkts` float DEFAULT 0,
  `bwd_pkts` float DEFAULT 0,
  `fwd_max` float DEFAULT 0,
  `fwd_rate` float DEFAULT 0,
  `fwd_mean` float DEFAULT 0,
  `idle_mean` float DEFAULT 0,
  `pkt_size_avg` float DEFAULT 0,

  -- AI model outputs
  `prob_brute` float DEFAULT 0,
  `prob_dos` float DEFAULT 0,
  `prob_adv_dos` float DEFAULT 0,
  `prob_loic` float DEFAULT 0,
  `prob_hoic` float DEFAULT 0,
  `selected_model` varchar(100) DEFAULT NULL,
  `selected_score` float NOT NULL,

  -- Classification result
  `threat_type` varchar(50) DEFAULT NULL,
  `action` varchar(20) NOT NULL,

  -- App / service context
  `service_name` varchar(100) DEFAULT NULL,
  `app_name` varchar(100) DEFAULT NULL,
  `app_package` varchar(200) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,

  PRIMARY KEY (`id`),
  KEY `idx_fl_user_id` (`user_id`),
  KEY `idx_fl_created_at` (`created_at`),
  KEY `idx_fl_action` (`action`),
  KEY `idx_fl_service_name` (`service_name`),
  KEY `idx_fl_app_name` (`app_name`),
  CONSTRAINT `fk_fl_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

---

## 2. Backend API Endpoints

### 2.1 Auth

| Method | Endpoint | Request Body | Notes |
|--------|----------|-------------|-------|
| POST | `/auth/register` | `{ email, username, password }` | Returns user + tokens |
| POST | `/auth/login` | `{ email, password }` | Returns access + refresh tokens |
| POST | `/auth/refresh` | `{ refresh_token }` | Rotates JWT |
| PUT | `/users/me` | `{ username?, new_password?, current_password }` | `current_password` required when changing password |

---

### 2.2 Blacklist

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/blacklist` | Returns entries with `bf_score`, `dos_score`, `reason` |
| POST | `/blacklist` | `{ ip, reason?, notes? }` — manual add |
| DELETE | `/blacklist/{id}` | Remove entry |

Backend also auto-inserts when a firewall log with `action = "blocked"` is posted (if IP not already present).

---

### 2.3 ACL

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/acl` | Returns whitelisted IPs |
| POST | `/acl` | `{ ip, notes? }` |
| DELETE | `/acl/{id}` | |

---

### 2.4 Settings

| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/settings` | Returns full `user_settings` row |
| PUT | `/settings` | Update any combination of fields |

Fields: `block_threshold`, `warn_threshold`, `flood_detection`, `syn_flood_detection`, `flood_pkt_per_sec`, `syn_flood_per_sec`, `bf_model_enabled`, `dos_model_enabled`, `max_log_entries`, `log_system_traffic`

---

### 2.5 Hardware Metrics

| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/hardware-metrics` | `{ cpu_usage, ram_used_mb, ram_total_mb, battery_level }` |
| GET | `/hardware-metrics` | Returns history for admin dashboard charts; supports `from_date`, `to_date` |


---
