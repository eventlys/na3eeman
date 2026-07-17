import json
import uuid

table_md = """
| Application Performance Monitoring (APM) | Datadog, New Relic, Dynatrace, Elastic APM, Sentry Performance, Grafana Cloud, Honeycomb, AppSignal, Scout APM |
| Infrastructure Monitoring | Prometheus + Grafana, Grafana Cloud, Datadog Infrastructure, New Relic Infrastructure, VictoriaMetrics, Zabbix, Checkmk |
| Centralized Logging | Grafana Loki, Elastic Stack (ELK), OpenSearch, Datadog Logs, Splunk, Graylog, Better Stack Logs |
| Distributed Tracing | OpenTelemetry, Jaeger, Zipkin, Grafana Tempo, Elastic APM |
| Error Tracking / Crash Reporting | Sentry, Rollbar, Bugsnag, Raygun, Crashlytics (mobile), Honeybadger |
| Real User Monitoring (RUM) | Datadog RUM, New Relic Browser, Grafana Faro, Elastic RUM, Sentry Session Replay |
| Website Analytics | Google Analytics 4, Plausible, Matomo, Fathom Analytics, Mixpanel, Amplitude |
| Product Analytics (Mobile & Web) | Mixpanel, Amplitude, PostHog, Heap, Countly |
| Session Recording / Heatmaps | Microsoft Clarity, Hotjar, FullStory, LogRocket, Smartlook |
| Status Page | Better Stack Status, Atlassian Statuspage, Instatus, Cachet, Uptime Kuma |
| Uptime Monitoring | Uptime Kuma, Better Stack, Pingdom, UptimeRobot, Freshping, Datadog Synthetics |
| Synthetic Monitoring | Checkly, Datadog Synthetics, New Relic Synthetics, Grafana Synthetic Monitoring, Pingdom |
| Incident Management | PagerDuty, Opsgenie, Splunk On-Call, Better Stack Incident Management, Incident.io, FireHydrant |
| Alerting | Grafana Alerting, Alertmanager, PagerDuty, Opsgenie, Better Stack, Datadog Monitors |
| Secrets Management | HashiCorp Vault, Google Secret Manager, Doppler, Infisical, AWS Secrets Manager |
| Identity & Authentication | Keycloak, Auth0, Firebase Authentication, Clerk, FusionAuth, Okta |
| API Gateway / API Management | Kong, Apigee, KrakenD, Tyk, Traefik Hub, Ambassador |
| Rate Limiting / Bot Protection / WAF | Cloudflare WAF, Google Cloud Armor, Imperva, AWS WAF, F5 |
| API Documentation | Swagger/OpenAPI, Redoc, Stoplight, Scalar, Postman API Docs |
| API Testing / Monitoring | Postman Monitors, Bruno, Insomnia, ReadyAPI, Hoppscotch |
| Background Jobs / Task Queue Monitoring | Celery Flower, Dramatiq Dashboard, Temporal, Bull Dashboard |
| Feature Flags | LaunchDarkly, Flagsmith, Unleash, ConfigCat, GrowthBook |
| User Feedback | Canny, UserVoice, Featurebase, Productboard, Frill |
| Email Delivery | SendGrid, Mailgun, Postmark, Amazon SES, Resend |
| Push Notifications | Firebase Cloud Messaging, OneSignal, Airship, AWS SNS |
| Search Engine | Elasticsearch, OpenSearch, Meilisearch, Typesense, Algolia |
| Object Storage / File Uploads | Google Cloud Storage, Cloudflare R2, Backblaze B2, MinIO |
| CDN (Static Assets) | Cloudflare CDN, Google Cloud CDN, Bunny.net, Fastly, Akamai |
| Database Backups | pgBackRest, WAL-G, Barman, Google Cloud Backup, Percona Backup |
| Database Monitoring | pgAdmin, pgwatch2, pganalyze, Datadog Database Monitoring, New Relic Database |
| Database Connection Pooling | PgBouncer, Odyssey |
| CI/CD | GitHub Actions, GitLab CI/CD, Jenkins, Argo CD, Google Cloud Build |
| Dependency Scanning | Dependabot, Renovate, Snyk, Mend (WhiteSource) |
| Secret Scanning | Gitleaks, GitGuardian, TruffleHog |
| Container Registry | Artifact Registry, GitHub Container Registry, Harbor, Docker Hub, GitLab Registry |
| Kubernetes Management | Argo CD, Rancher, Lens, Portainer, OpenLens |
| Load Testing | k6, JMeter, Locust, Gatling, Artillery |
| API Load Testing | k6, Vegeta, Locust, Postman Performance Testing |
| Monitoring Dashboards | Grafana, Kibana, Datadog Dashboards, New Relic Dashboards |
| Business Intelligence (BI) | Metabase, Looker Studio, Superset, Power BI, Tableau |
| Data Warehouse | BigQuery, Snowflake, ClickHouse, Redshift |
| Customer Support / Live Chat | Intercom, Crisp, Zendesk, Freshchat, Tidio |
| Consent / Cookie Management | Cookiebot, OneTrust, Usercentrics, CookieYes |
"""

service_to_cats = {}

# Clean up common variations so they group correctly
def normalize_service(s):
    s = s.strip()
    norm = s.lower()
    if 'datadog' in norm: return 'Datadog'
    if 'sentry' in norm: return 'Sentry'
    if 'grafana' in norm: return 'Grafana'
    if 'new relic' in norm: return 'New Relic'
    if 'elastic' in norm: return 'Elastic Stack'
    if 'cloudflare' in norm: return 'Cloudflare'
    if 'google cloud' in norm or 'gcp' in norm or 'google' in norm and 'analytics' not in norm and 'looker' not in norm: return 'Google Cloud'
    if 'better stack' in norm: return 'Better Stack'
    if 'uptime kuma' in norm: return 'Uptime Kuma'
    if 'postman' in norm: return 'Postman'
    if 'firebase' in norm: return 'Firebase'
    if 'aws' in norm or 'amazon' in norm: return 'AWS'
    if 'gitlab' in norm: return 'GitLab'
    if 'github' in norm: return 'GitHub'
    if 'mixpanel' in norm: return 'Mixpanel'
    if 'amplitude' in norm: return 'Amplitude'
    if 'pagerduty' in norm: return 'PagerDuty'
    if 'opsgenie' in norm: return 'Opsgenie'
    if 'k6' in norm: return 'k6'
    if 'locust' in norm: return 'Locust'
    if 'pingdom' in norm: return 'Pingdom'
    return s

for line in table_md.strip().split('\n'):
    parts = [p.strip() for p in line.split('|') if p.strip()]
    if len(parts) >= 2:
        cat = parts[0].replace('*', '').strip()
        alts = parts[1].split(', ')
        for alt in alts:
            svc = normalize_service(alt)
            if svc not in service_to_cats:
                service_to_cats[svc] = []
            if cat not in service_to_cats[svc]:
                service_to_cats[svc].append(cat)

# Sort by number of categories to show the most versatile services first
sorted_services = sorted(service_to_cats.items(), key=lambda x: len(x[1]), reverse=True)

elements = []
y_offset = 0
x_offset = 0

for svc, cats in sorted_services:
    cat_text = "\n".join(["• " + c for c in cats])
    cat_height = max(len(cats) * 20 + 40, 60)
    
    # Service box (Left)
    elements.append({
        "id": str(uuid.uuid4()), "type": "rectangle", "x": x_offset, "y": y_offset,
        "width": 300, "height": 50, "strokeColor": "#c92a2a", "backgroundColor": "#ffc9c9",
        "fillStyle": "solid", "strokeWidth": 2, "strokeStyle": "solid", "roundness": {"type": 3}
    })
    elements.append({
        "id": str(uuid.uuid4()), "type": "text", "x": x_offset + 10, "y": y_offset + 15,
        "width": len(svc) * 10, "height": 20, "originalText": svc,
        "text": svc, "fontSize": 16, "fontFamily": 1, "strokeColor": "#000000",
        "textAlign": "left", "verticalAlign": "top"
    })
    
    # Categories box (Right)
    elements.append({
        "id": str(uuid.uuid4()), "type": "rectangle", "x": x_offset + 380, "y": y_offset,
        "width": 450, "height": cat_height, "strokeColor": "#2b8a3e", "backgroundColor": "#b2f2bb",
        "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid", "roundness": {"type": 3}
    })
    elements.append({
        "id": str(uuid.uuid4()), "type": "text", "x": x_offset + 390, "y": y_offset + 10,
        "width": 430, "height": cat_height - 20, "originalText": cat_text,
        "text": cat_text, "fontSize": 14, "fontFamily": 1, "strokeColor": "#000000",
        "textAlign": "left", "verticalAlign": "top"
    })
    
    # Arrow (From Service to Categories)
    elements.append({
        "id": str(uuid.uuid4()), "type": "arrow", "x": x_offset + 300, "y": y_offset + 25,
        "width": 80, "height": 0, "strokeColor": "#000000", "strokeWidth": 2,
        "points": [[0,0], [80,0]], "endArrowhead": "arrow"
    })
    
    y_offset += cat_height + 30
    if y_offset > 3000:
        y_offset = 0
        x_offset += 950

data = {"type": "excalidraw", "version": 2, "source": "https://excalidraw.com", "elements": elements}
with open("/home/azeez/Documents/proj/na3eeman/TechStack_Diagram.excalidraw", "w") as f:
    json.dump(data, f)
