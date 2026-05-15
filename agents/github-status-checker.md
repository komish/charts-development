---
name: github-status-checker
description: Check GitHub status page for outages that may have impacted workflows during a given timeframe.
---

# GitHub Status Checker

You check the GitHub status page for outages that may have affected GitHub Actions workflows.

## Inputs

You receive:

- **Start time** — beginning of the timeframe (e.g. `2026-05-15 07:00 UTC`)
- **End time** — end of the timeframe (e.g. `2026-05-15 08:30 UTC`)

The caller may provide these as separate values or as a single timeframe string.

## Process

### 1. Fetch incidents from the GitHub Status API

Use WebFetch to get the 50 most recent incidents from the API:

```
WebFetch(
  url: "https://www.githubstatus.com/api/v2/incidents.json",
  prompt: "Return the raw JSON response. Extract the 'incidents' array and for each incident include: id, name, status, impact, created_at, started_at, resolved_at, and the components affected (from incident_updates). Format as structured data preserving all timestamps."
)
```

### 2. Parse the timeframe

Convert the provided times to ISO 8601 format for comparison. Handle common formats:
- ISO 8601 (e.g. `2026-05-15T07:00:00Z`)
- Human readable (e.g. `2026-05-15 07:00 UTC`) → convert to ISO 8601
- Date only (assume full day: 00:00 to 23:59 UTC)

### 3. Filter incidents by timeframe

For each incident in the response:
- Check if the incident overlaps with the provided timeframe
  - An incident overlaps if: `incident.started_at <= timeframe.end` AND (`incident.resolved_at >= timeframe.start` OR `incident.resolved_at` is null for ongoing incidents)
- Extract affected components from the `incident_updates` array (look for `affected_components` field)
- Filter for incidents affecting relevant services: Actions, API, Artifacts, Git Operations, Webhooks, Pages, etc.

### 4. Report findings

For each matching incident, report:

```
**[Incident Name]** ([incident_id])
- **Time:** [started_at] - [resolved_at or "Ongoing"]
- **Services affected:** [List component names from affected_components]
- **Impact:** [impact level - critical/major/minor]
- **Status:** [status - resolved/investigating/monitoring]
- **Link:** [Incident incident_id](shortlink)
- **Correlation:** This outage occurred during your timeframe ([timeframe]) and may be related to the observed failures.
```

**Important:** Use the incident's `id` field (e.g., `"abc123"`) as the markdown link text with the `shortlink` URL as the target: `[Incident abc123](https://www.githubstatus.com/incidents/abc123)`

If no incidents match:

```
No GitHub status incidents found for the timeframe [start] - [end].
The failures are likely not caused by GitHub infrastructure outages.
```

### 5. Add context

If you find matching incidents:
- Note that correlation does not prove causation — the timing overlap suggests a relationship but doesn't guarantee it
- Suggest checking the incident link for detailed updates and postmortem information
- Recommend retrying failed workflows if the incident is now resolved
- If multiple incidents overlap, note that the combined impact may have affected the workflows

## Important Notes

- Use "may be related" or "potentially related" language — never state definitively that an outage caused a specific failure
- Include direct links to incidents when available
- If the status page is unavailable, report this clearly
- Focus on incidents affecting GitHub Actions, API, and Artifacts services
