# Na3eeman Admin Infrastructure & Operations Guide

This document outlines the infrastructure configuration and operational procedures for the newly implemented Admin Analytics Dashboard.

## 1. Google Cloud Platform (GCP) Configuration

### 1.1 Cloud Monitoring (Stackdriver)
To monitor the health and performance of the analytics module:
1. **Metrics Explorer**: Monitor the latency of `/api/analytics/*` endpoints. 
2. **Alerting Policies**:
   - **Endpoint Latency**: Alert if 95th percentile latency exceeds 2s.
   - **Error Rate (4xx/5xx)**: Alert if more than 1% of analytics requests result in errors.
   - **Unauthorized Access**: Alert on repeated 403 Forbidden responses to analytics endpoints.

### 1.2 Structured Logging
The backend uses Python's `logging` module with a dedicated `analytics` logger.
- **Log Source**: `na3eeman_be/analytics/views.py`
- **GCP Connector**: Ensure `google-cloud-logging` is installed and configured in `settings.py`.

## 2. Cloudflare Security & Caching

### 2.1 Bypass Caching for Admin Routes
Admin analytics data is dynamic and sensitive. It MUST NOT be cached on the edge.
- **Page Rule**:
  - Target: `api.na3eeman.com/api/analytics/*`
  - Setting: **Cache Level: Bypass**
  - Setting: **Edge Cache TTL: 0**

### 2.2 WAF Rules (Web Application Firewall)
- **Rate Limiting**: Limit `/api/analytics/*` to 10 requests per minute per IP.

---
*Created by Antigravity AI - [2026-03-27]*
