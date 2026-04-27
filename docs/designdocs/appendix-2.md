# Appendix 2 — Planning

---

## 2.1 Basic Plan / Gantt Chart

The project spans two academic quarters at UC Santa Cruz: Winter 2026 (January–March) and Spring 2026 (April–June). The plan is divided into four major phases: Research & Definition, Design & Architecture, Implementation & Prototyping, and Testing & Documentation.

### Project Timeline (Text-Based Gantt Chart)

```
Phase / Task                        Jan    Feb    Mar    Apr    May    Jun
                                   W1-W4  W5-W8  W9-W12 W13-16 W17-20 W21-24
─────────────────────────────────────────────────────────────────────────────
PHASE 1: Research & Definition
  Problem formulation                ████
  Brainstorming & concept gen        ████
  Existing product research            █████
  Persona development                     ██
  Need & goal statements              █████

PHASE 2: Design & Architecture
  System architecture design            ██████
  Communication protocol design             ██████
  ML pipeline design                    ██████
  Design document (initial draft)               ████
  Mobile app UI mockup                  ██
  Hardware procurement                 ██ 

PHASE 3: Implementation & Prototyping
  ML model integration & tuning          ███████████
  Backend setup (MQTT broker, DB,            ██████████
    fleet operator WebSocket)
  Flutter app development                  █████████   █████
  External alarm integration                           ██████
  Hardware mounting / enclosure                            ██████
  System integration                             ███   █████

PHASE 4: Testing & Documentation
  Unit testing (per subsystem)                         █████
  Integration testing                                      ██████
  Design document (final)                                    ██████
  Final presentation prep                                        ████

```
<!-- PLACEHOLDER: Imaybe include screenshot from Teamwork for how we split tasks -->

---

## 2.2 Division of Labor During Prototyping Phase

The team of six divided responsibilities based on individual expertise and interest areas. The table below shows the primary ownership of each subsystem during the prototyping phase, along with secondary contributors.

| Subsystem | Primary Owner(s) | Description |
|-----------|------------------|-------------|
| **ML Pipeline** | Jason, Soham | Face detection model selection, EAR computation, head pose estimation, camera integration, sliding window fatigue classification |
| **SoC → Phone Communication (BLE)** | Jason, Soham | BLE service/characteristic setup on SoC, drowsiness event packet format, connection management |
| **SoC → Backend Communication (MQTT)** | Jason, Soham | MQTT client on SoC, broker setup, event topic/payload design, WiFi connectivity |
| **SoC → External Alarm (Wired)** | Ricardo, Pravin | GPIO-driven alarm trigger, wired buzzer/speaker integration, signal timing |
| **Backend & Fleet Operator Interface** | Jason, Soham | MQTT event consumer, PostgreSQL schema design, WebSocket gateway for fleet operator notification |
| **Flutter Mobile App** | Pranav, Pravin, Alejandro, Ricardo | UI/UX design, BLE client, alert display (audio/vibration/visual), rerouting suggestions, connection status |
| **Hardware & Enclosure** | Alejandro, Pranav | Device mounting, IR camera selection and positioning, power supply (12V vehicle adapter), physical enclosure/housing, external alarm mounting |
| **Documentation & Testing — ML Pipeline & Integration** | Jason, Soham | Design document coordination, appendices (problem formulation, planning), test plan development, integration testing across all three alert paths |
| **Documentation & Testing — Mobile App** | Pranav, Pravin, Alejandro, Ricardo | Design document coordination, appendices (problem formulation, planning), test plan development |


## 2.3 Collaboration

### Repository Structure

The team uses a shared GitHub repository as the single source of truth for all project code and documentation. 

### Branching Strategy

The team follows a feature-branch workflow:

1. Each team member creates a feature branch from `main` for their work (e.g., `feature/mqtt-broker`, `feature/flutter-alerts`, `feature/ble-service`, `feature/external-alarm`).
2. When a feature is complete, the member opens a Pull Request (PR) for code review.
3. At least one other team member reviews the PR before merging into `main`.
4. Team members regularly pull from `main` into their feature branches to stay in sync and reduce merge conflicts.

### Task Management with Teamwork

Beyond the Git repository, the team uses **Teamwork** as the primary project management tool. Teamwork is used for:

- **Task assignment:** Each task is assigned to a team member with a due date. Tasks correspond to the subsystems in the division of labor table above.
- **Milestone tracking:** Key milestones from the Gantt chart are tracked as Teamwork milestones, allowing the team to monitor progress at a glance.
- **Task lists and subtasks:** Larger deliverables (e.g., "Flutter app development") are broken into subtasks (e.g., "Implement BLE client," "Design alert UI," "Add vibration/audio alerts," "Implement rerouting suggestions") and tracked individually.

### Communication

- **Regular meetings:** The team meets twice a week to discuss progress, blockers, and upcoming tasks. Meeting notes are shared in a Google Doc
- **Asynchronous communication:** Day-to-day questions and quick updates are handled via Discord
- **Design reviews:** Major design decisions (such as the communication protocol selection documented in Appendix 1) are discussed as a full team before implementation begins.

### Tools Summary

| Tool | Purpose |
|------|---------|
| **GitHub** | Version control, code review (PRs), documentation hosting |
| **Teamwork** | Task assignment, milestone tracking, project timeline |
| **Discord**  | Real-time communication |
| **Google Docs** | Meeting notes, shared drafts |
| **Figma** | Design schematic |
