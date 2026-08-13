---
name: production-planning
description: "Production planning for marketing campaigns — shoot-day checklists, equipment manifests, timeline templates, per-project budget templates, contingency planning, vendor and crew sourcing, on-set logistics."
user-invocable: true
allowed-tools: [Read, Glob, Grep, Write]
---

# Production Planning Skill

Canonical templates and decision matrices for planning marketing-production engagements across photography, video, broadcast, and cinematic shoots. Used by `executive-producer`, `shot-list-designer`, and the `/production-brief` command. This skill is industry-agnostic; per-profile adjustments are captured in §8.

## 1. Shoot Day Checklist

### Pre-Shoot (day before)

- Camera and audio batteries charged; spare set packed
- Memory cards formatted; primary + redundant cards labeled
- Gear checklist packed: bodies, lenses, lighting, modifiers, stands, sandbags, grip
- Location address confirmed in writing with venue contact
- Shot list reviewed by DP, gaffer, sound op, and producer
- Weather pulled at T-24h and T-2h for outdoor shoots; B-plan rehearsed
- Permits in physical and digital folder on-set; insurance COI attached
- Backup gear identified and accessible (rented body, rental house on speed-dial)
- Call sheet distributed to every crew member and talent

### Day-of timeline

| Time   | Activity                  | Notes |
|--------|---------------------------|-------|
| T-90m  | Producer + DP scout       | Light walk, blocking |
| T-60m  | Crew arrives, load-in     | Lighting + grip first |
| T-30m  | Talent + client greeted   | Holding, hair/makeup |
| T-0    | First shot                | Hero coverage |
| T+2h   | First break + dailies     | Cull review |
| T+4h   | Lunch (union: 6h max)     | Penalty after |
| T+6h   | Coverage shots            | Wide / med / close / detail |
| T+8h   | Wrap, load-out, sign-off  | Talent releases countersigned |

### Post-shoot

- Transfer to primary + secondary drive before leaving location
- RAW backed to LTO or cloud cold-storage within 24h
- Initial cull (1-star keepers) within 48h
- Edit selects to client by agreed date
- Talent / location releases filed to `output/campaigns/<id>/production/releases/`

## 2. Production Timeline Template

| Phase           | Duration | Deliverables                                                                 | Owner               |
|-----------------|----------|------------------------------------------------------------------------------|---------------------|
| Pre-production  | 2-4 wk   | Shot list, schedule, budget, crew booked, locations scouted, releases drafted| executive-producer  |
| Shoot           | 1-5 d    | RAW captures, on-set dailies, signed releases, BTS reference                 | executive-producer  |
| Post-production | 2-6 wk   | Selects, color, sound, VFX, motion, finals at all delivery ratios            | executive-producer  |
| Delivery        | 1 wk     | Distribution-ready masters, captions, alt-text, archival package             | executive-producer  |

## 3. Per-Project Budget Template

| Category                                 | Estimated | Actual | Notes                              |
|------------------------------------------|-----------|--------|------------------------------------|
| Equipment rental                         | $         | $      | Bodies, lenses, lighting, grip     |
| Travel / mileage                         | $         | $      | IRS rate; flights; ground          |
| Crew — assistant                         | $         | $      | Day rate × days                    |
| Crew — second shooter                    | $         | $      | Photography only                   |
| Crew — DP                                | $         | $      | Video                              |
| Crew — gaffer                            | $         | $      | + electrics                        |
| Crew — sound op                          | $         | $      | + boom op when needed              |
| Talent fees                              | $         | $      | Day rate + usage                   |
| Styling / makeup / wardrobe              | $         | $      | Includes kit fee                   |
| Location fees + permits                  | $         | $      | City film office + venue           |
| Props / supplies                         | $         | $      | Buy-back vs rent                   |
| Catering                                 | $         | $      | $25-50 / head minimum              |
| Post-production                          | $         | $      | Edit + color + sound + motion      |
| Delivery / distribution                  | $         | $      | DCP, master files, captions        |
| Contingency (10-15%)                     | $         | $      | Mandatory line                     |
| **Total**                                | **$**     | **$**  |                                    |

## 4. Crew Sourcing Patterns

| Role             | Day rate (USD) | Book-by lead time | Sourcing channel                              |
|------------------|----------------|-------------------|-----------------------------------------------|
| Second shooter   | 400-1,200      | 2 wk              | Local guild, ASMP, prior collaborators        |
| DP               | 800-3,500      | 3-6 wk            | Cinematographer roster, Production Hub        |
| Gaffer           | 600-1,500      | 2-4 wk            | IATSE Local 728/52 (US), referrals            |
| Sound op         | 500-1,200      | 2 wk              | Production sound mixer roster                 |
| Stylist          | 600-1,800      | 2-3 wk            | The Wall Group, agency reps                   |
| Makeup           | 500-1,200      | 2 wk              | Exclusive Artists, agency reps                |
| Hair             | 500-1,200      | 2 wk              | Same as makeup                                |
| Wardrobe         | 500-1,200      | 2 wk              | Costume designers guild                       |
| PA               | 200-400        | 1 wk              | Local film-school networks                    |
| Talent agent     | n/a (commission)| 3-6 wk           | SAG-AFTRA, ICM, CAA, WME, boutique            |

## 5. Equipment Manifest by Project Type

| Project type            | Bodies                | Lenses                          | Lighting                        | Audio                | Grip / support         |
|-------------------------|-----------------------|----------------------------------|---------------------------------|----------------------|------------------------|
| Portrait                | 1-2 stills bodies     | 35 / 50 / 85 / 135               | 1 key + 1 fill + reflector      | n/a                  | C-stand, V-flat        |
| Event                   | 2 stills bodies       | 24-70 / 70-200 / 35 prime        | On-camera + 1 off-camera        | Lav optional         | Monopod, fast-pack     |
| Commercial product      | 1 stills + tethered   | 100 macro, 50 mid, TS-E          | 2-3 strobes + table-top         | n/a                  | Cam-stand, flag kit    |
| Lifestyle commercial    | 2 stills + 1 video    | 24-70 / 70-200 / primes          | Mixed natural + HMI fill        | Lav + boom optional  | Dolly / slider         |
| Documentary             | 1-2 video bodies      | 24-105 / 70-200                  | Bounce + practicals             | Lav + boom + recorder| Shoulder rig, gimbal   |
| Cinematic narrative     | Cinema body (Alexa/Venice/Komodo) | Prime set 18-100        | HMI + LED + Tungsten + grip pkg | Boom + lav + mixer + cart | Dolly + slider + crane |

## 6. Contingency Planning

| Risk                | Plan A                     | Plan B                                  | Decision trigger             |
|---------------------|----------------------------|------------------------------------------|------------------------------|
| Weather (outdoor)   | Original location          | Pre-scouted covered alt; or shift day    | NOAA forecast >40% precip T-12h |
| Equipment failure   | Primary kit                | Same-day rental from local house          | Failed body / lens / strobe  |
| Talent no-show      | Booked talent              | Standby talent on hold; or reshoot date   | No contact by T-30m          |
| Permit denial       | Filed permit               | Pre-cleared alt location                  | Denial 48h before shoot      |
| Power loss          | Venue power                | Battery + portable generator              | Genny on-site for cinematic  |

## 7. On-Set Problem-Solving Heuristics

1. Always have a Plan B for weather, gear, talent, permit, and power.
2. Pull weather at T-24h and T-2h; communicate B-plan to crew at T-24h.
3. Brief crew on the shot list before the client arrives — never in front of the client.
4. Transfer to two drives before anyone leaves the location.
5. Never delete from a card until RAW is verified on two destinations.
6. Hold a 6-minute reset every 90 minutes — energy collapses cause the most reshoots.
7. The producer protects the DP's focus; clients and talent route through the producer.
8. Document any deviation from the shot list in the dailies log within 30 minutes.
9. Sign every release on the day; chasing signatures post-wrap kills downstream usage.
10. Wrap is not over until gear is loaded, drives are duplicated, and releases are filed.

## 8. Industry Adaptation Notes

- **B2B SaaS** — mostly digital shoots: talking-head testimonials, screen captures, animated product demos. Lighter crew (DP + sound + producer). Budget heavier on post-motion than on-set crew.
- **DTC e-commerce** — product photography, lifestyle stills, UGC. High-volume shoot days (60-150 SKUs/day for catalogue). Tethered capture mandatory; on-set art director.
- **Professional services** — corporate headshots and case-study video. Discreet crew, executive-friendly schedule, NDAs for crew. Confidentiality > spectacle.
- **Regulated (health/finance)** — every shoot day ends with a compliance review of captures against the regulated-claims-review gate. MLR observer often required on set.
- **Creative-production** — full filmcraft discipline: cinematic narrative, full grip + electric + camera departments, DIT on-set, dailies pipeline to post.
- **Advertising-commercial** — largest crews. Agency producer + creative director on-set; client present. Union shoot rules (IATSE / DGA / SAG-AFTRA) typically apply. Dailies and approvals in real time.
