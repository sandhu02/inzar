# Inzar — Mobile App UI/UX Design Brief

## 1. Product Overview

Design a modern, production-quality mobile application called **Inzar** — a crowdsourced, AI-verified, real-time incident reporting and local awareness platform.

The app allows people to capture real-world incidents using the app's built-in camera, submit a photo, select an emergency classification (other if none match) and description, and share the report with nearby users. An AI verification service checks whether the submitted photo and description correspond to the selected incident category. Approved reports appear on a live map, filtered by the user's chosen radius.

Example incidents include:
- Wildfires, smoke, and other fire hazards
- Road accidents and vehicle collisions
- Road blockages, traffic disruptions, and closures
- Flooding, fallen trees, and damaged infrastructure
- Protests, public gatherings, and major local disruptions
- Other immediate public safety concerns

The goal is to help users quickly understand what is happening around them and make informed decisions.

This is not a conventional social network. Avoid feeds optimized for engagement, likes, followers, comments, or viral content. The product should prioritize useful information, trust, location relevance, and speed.

## 2. Core Design Philosophy

Follow these principles throughout the entire application:

1. **Map first:** The main screen should immediately communicate what is happening nearby.
2. **Minimal interaction:** Reporting an incident should take as few steps as reasonably possible.
3. **Speed over decoration:** Avoid unnecessary animations, large illustrations, excessive cards, and visual clutter.
4. **Progressive disclosure:** Show essential information first. Reveal secondary details only when requested.
5. **Trust through transparency:** Clearly distinguish AI review, verified reports, pending reports, and rejected submissions.
6. **Mobile-first:** Design for one-handed operation, particularly when users need to report a time-sensitive situation.
7. **Privacy by default:** Never publicly expose a reporter's precise personal location or identity unnecessarily.
8. **Functional realism:** Every screen, button, menu, loading state, and navigation action must have a clear purpose.

Aim for a polished, lightweight Android application with a native-feeling interface. The design should be practical to implement using Kotlin and Jetpack Compose.

## 3. Visual Identity and Design System

### Brand personality

The brand should feel:
- Dependable
- Immediate
- Calm under pressure
- Community-powered
- Technologically intelligent
- Neutral and informative

Do not make it look like a military command dashboard, a gaming interface, or an overly dramatic disaster-response application.

### Suggested visual direction

Use a refined dark-first interface optimized for map readability and outdoor use.

Suggested palette:
- Background: #101318
- Primary surface: #191E25
- Elevated surface: #222A34
- Primary accent: #A7F36B
- Main text: #F3F5F7
- Secondary text: #A2ABB8
- Danger: #FF5B5B
- Warning: #FFB547
- Informational: #69BFFF
- Success: #62D99A

Use the accent color sparingly for primary actions, selected controls, location indicators, and successful states. Use category-specific colors for incident markers, but ensure colors are not the only way to distinguish categories.

Support light mode as a secondary theme, with appropriate contrast and map styling.

### Typography

Use a clean, highly legible sans-serif typeface such as Roboto or Inter.

- Clear, compact screen titles
- Readable incident titles and descriptions
- Small but legible timestamps and distance labels
- Strong contrast between primary information and metadata
- Consistent typography hierarchy

### Components

Create a consistent component library containing:
- Primary and secondary buttons
- Icon buttons
- Search and filter controls
- Bottom navigation
- Bottom sheets
- Incident markers
- Incident category chips
- Status badges
- Compact incident cards
- Radius selector
- Loading skeletons
- Empty states
- Error banners
- Permission prompts
- Confirmation dialogs
- Toasts or brief status messages

Use rounded corners moderately, approximately 12–18 dp for cards and sheets. Keep controls comfortable to tap, targeting approximately 48 dp touch areas.

Use simple, consistent line icons. Avoid unnecessary gradients, excessive shadows, and glassmorphism.

## 4. Navigation Architecture

Use a minimal bottom navigation with three destinations:

1. **Map** — primary destination and default launch screen.
2. **Activity** — the user's submitted reports and their review statuses.
3. **Settings** — preferences, privacy, notifications, and app configuration.

Provide a prominent floating report button on the map screen. It must be immediately discoverable without competing with the map.

Do not introduce additional top-level destinations unless there is a compelling functional reason.

The primary navigation should remain predictable and consistent across screens.

## 5. Screen 1 — Main Map

This is the most important screen. Spend the greatest design effort here.

The map should occupy almost the entire available screen, with minimal UI layered on top.

### Layout

Top overlay:
- Small Inzar logo or wordmark
- Current location or selected area
- Search or location lookup button
- Notification or alert settings shortcut, if needed

Map:
- User's approximate current location
- Incident markers with recognizable category icons
- Visually distinct markers for urgent incidents
- Marker clustering when several incidents overlap
- A subtle radius boundary when radius filtering is enabled
- A recenter-to-current-location button

Bottom overlay:
- A compact radius selector, for example 1 km, 5 km, 10 km, 25 km, and 50 km
- A concise count of incidents currently within the selected radius
- A prominent floating action button labelled "Report"

Keep the radius control compact. A segmented selector or horizontal chip row is preferred over a large settings panel.

Avoid placing a permanently expanded incident feed over the map.

### Map behavior

- Display incidents within the selected radius of the user's chosen center point.
- Refresh visible incidents when the map area or radius changes.
- Keep map panning and zooming smooth.
- Do not reset the map unexpectedly when an incident is selected or the app resumes.
- Use clustered markers at lower zoom levels.
- Clearly indicate when location permission is unavailable.
- Offer a manual location or map-center selection as a fallback.
- Show a compact loading state while incidents are being fetched.
- Show a useful empty state when no incidents are found.

### Selecting an incident marker

When a user taps a marker, open a compact bottom sheet instead of navigating immediately to another screen.

The preview should show:
- Incident category and short title
- Incident photo thumbnail, if available
- Approximate distance from the user's selected location
- Time reported
- Verification status
- A short description
- A "View details" action

Allow the user to dismiss the sheet and continue exploring the map.

## 6. Screen 2 — Incident Details

Design a focused incident detail screen that communicates useful facts quickly.

### Content hierarchy

1. Incident category and title
2. Verification or review status
3. Original incident photo
4. Description provided by the reporter
5. Time reported and last updated time
6. Approximate location and distance
7. Map preview with the incident location
8. Current incident status
9. Relevant safety information, if available

### Actions

Provide only useful, context-appropriate actions:
- Get directions or open the location in a maps application
- Share the incident
- Report incorrect information or abuse
- Mark as resolved, if the backend supports authorized or community resolution reports

Do not expose the reporter's personal contact details.

Do not present AI classification as proof that an incident is factually confirmed. Use precise labels such as "AI reviewed" or "Community corroborated" according to the actual verification performed.

If the incident may be outdated, show an age indicator and any available last-confirmed timestamp.

## 7. Screen 3 — Report an Incident

The reporting workflow is the second most important part of the application.

The ideal experience should allow a user to submit a report in approximately 10–20 seconds under normal conditions, excluding the time required to take the photo or wait for network transmission.

Use a short, focused flow with minimal unnecessary navigation.

### Step A: Capture the incident

Open the app's built-in camera directly.

Camera interface:
- Full-screen camera preview
- Large shutter button near the bottom
- Flash toggle when supported
- Camera switch only if needed
- Clear close or back button
- Minimal camera controls
- Small guidance text: "Capture what's happening"

The app must capture a new photo through its own camera workflow. Do not provide gallery selection, file browsing, or an option to upload an existing photo.

Do not design a gallery icon, recent-photo picker, or alternate photo-import flow.

After capture, show a lightweight preview with:
- Retake
- Continue

If camera permission is denied, explain why it is required and offer a way to open system settings when necessary.

### Step B: Describe the incident

Show a compact form containing:

**Incident category**

Use selectable icon chips or a compact grid for:
- Fire / Wildfire
- Accident
- Road blockage
- Flooding
- Public gathering / Protest
- Other hazard

The category list must be extensible.

**Description**

Provide a short text field with a helpful placeholder, such as:

"Describe what is happening, any immediate danger, and relevant nearby landmarks..."

Keep the field concise and easy to complete.

**Location**

Automatically obtain the device's current location, subject to permission.

Display a human-readable location or nearby landmark when available, along with a small map preview. Allow the user to adjust the reported location if necessary.

Avoid exposing precise reporter coordinates publicly. The incident location can be shown at an appropriate level of precision based on the product's safety and privacy rules.

**Submit button**

Use one prominent action: "Submit report".

Before submission, provide concise feedback if a required field is missing. Avoid lengthy forms and unnecessary confirmation dialogs.

### Step C: Submission and AI review

After submission, show an explicit progress state.

Suggested status sequence:
- Uploading photo
- Checking report
- Published, if approved
- Needs review, if inconclusive
- Not approved, if rejected

Do not imply that AI review is instantaneous if processing is still underway.

The interface must handle the possibility that the photo uploads successfully but AI review is delayed or temporarily unavailable.

If the report is pending review, let the user leave the screen and track the report in Activity.

Do not force users to remain on a loading screen while the backend processes the report.

## 8. AI Verification and Trust States

Design clear states for the server-side verification process.

### Approved

The image and description appear sufficiently consistent with the submitted category, and the backend approves publication.

Show:
- A successful submission message
- A concise AI-reviewed label
- An option to return to the map
- The ability to view the submitted report

### Pending review

The AI system cannot confidently determine whether the image and description match, or the system needs additional review.

Show:
- "Under review"
- A short explanation
- The report's current status
- No misleading claim of confirmation

### Rejected

The image does not match the claimed incident, the description is inconsistent, or the submission violates the platform's rules.

Show:
- "Report not approved"
- A clear, neutral reason where available
- An option to correct and resubmit when appropriate

### Verification limitations

The UI must distinguish image/category consistency from independent proof that an incident actually occurred.

Do not claim that AI has confirmed the incident's exact location, severity, authenticity, or present status unless those capabilities are independently supported.

Use a restrained trust system. Avoid arbitrary confidence percentages or invented verification scores.

## 9. Screen 4 — Activity / My Reports

Provide a lightweight history of the user's submissions.

Each report row or card should contain:
- Small photo thumbnail
- Incident category and title
- Submission time
- Current review status
- Approximate location

Support simple filters:
- All
- Under review
- Published
- Not approved

Opening a report should display its details and current status.

Include sensible empty states, such as:

"You haven't submitted any reports yet."

Provide a direct action to return to the map and report an incident.

Do not add likes, followers, engagement statistics, or social-media-style profile metrics.

## 10. Screen 5 — Settings and Permissions

Keep settings short and practical.

Include:

### Map preferences
- Default search radius
- Map display preferences
- Default map-center behavior

### Notifications
- Nearby incident alerts
- Alert radius
- Incident categories of interest
- Urgency preferences, where supported

### Permissions
- Location access
- Camera access
- Notification permission

Explain denied permissions in plain language. Do not repeatedly interrupt the user with permission prompts.

### Privacy and account
- Privacy policy
- Data and location handling explanation
- Account management, if accounts are implemented
- Sign out, if applicable
- Delete account, if applicable

### Appearance
- System default
- Light mode
- Dark mode

Avoid unnecessary settings that belong to an administrative dashboard rather than a consumer app.

## 11. Nearby Alerts and Notifications

Design concise notifications for meaningful local incidents.

Example:

**Wildfire reported nearby**
"Smoke and fire reported 2.4 km away. View incident."

Other examples include road closures, accidents, flooding, and major disruptions.

Notification behavior should:
- Respect the user's chosen radius and categories.
- Avoid repeatedly notifying the user about the same incident.
- Support updated or resolved incidents where useful.
- Distinguish high-priority hazards from routine disruptions.
- Avoid claiming that an incident is dangerous solely because of its category.

Do not make every new report trigger an urgent notification.

Use sensible grouping and throttling to avoid alert fatigue.

Include the relevant notification permission and disabled-notifications states in the design.

## 12. Essential UX States

Do not design only the ideal, fully populated application. Include realistic edge cases.

### Map states
- Loading incidents
- Incidents available
- No incidents nearby
- Location permission denied
- Location unavailable
- Network unavailable
- Map data failed to load

### Camera and submission states
- Camera permission not granted
- Camera unavailable
- Photo captured
- Photo rejected by local validation, if supported
- Uploading
- Upload failed
- Retry available
- AI review pending
- AI review failed or unavailable
- Report approved
- Report rejected

### Data states
- No previous reports
- Reports loading
- Reports failed to load
- Incident removed or no longer available
- Incident marked resolved or stale

Error messages should be short, actionable, and nontechnical.

Preserve user-entered text and the captured photo where safe and technically feasible when a submission fails. Never silently discard a report.

## 13. Performance and Responsiveness

Performance is a core product requirement, not merely a visual preference.

Design the interface to support:
- Immediate display of the map shell while data loads.
- Fast navigation without unnecessary screen transitions.
- Optimistic local UI updates where safe.
- Lazy loading of incident thumbnails and details.
- Small, compact incident previews.
- Smooth map interactions and marker selection.
- Skeleton loading instead of blank screens.
- Background upload and review tracking where supported.
- Clear retry actions when connectivity fails.

Use subtle, fast transitions. Prefer short fades, small slides, and natural bottom-sheet motion. Avoid elaborate animated introductions, splash-screen sequences, and full-screen transitions for routine actions.

Never block the entire interface while fetching incidents or processing a report if the user can safely continue using the app.

Keep the report flow resilient to slow mobile networks and intermittent connectivity.

## 14. Accessibility and Outdoor Usability

- Maintain strong text contrast in both themes.
- Do not rely exclusively on red, yellow, or green to communicate statuses.
- Provide descriptive accessibility labels for map markers and icon-only buttons.
- Use appropriately sized touch targets.
- Support system font scaling.
- Avoid tiny map overlay controls.
- Make urgent information scannable in a few seconds.
- Use clear language rather than technical AI terminology.
- Ensure status and error information is accessible to screen readers.

## 15. Privacy and Safety Considerations

Design with the understanding that incident reports can involve sensitive locations, active protests, accidents, and potentially vulnerable individuals.

- Do not display the reporter's personal identity by default.
- Avoid exposing the reporter's exact GPS position.
- Do not add face recognition or automatic identification of individuals.
- Do not design public profiles that reveal a user's reporting history and movements.
- Allow users to flag misleading, abusive, or dangerous content.
- Account for outdated reports and false positives.
- Distinguish reported information from independently corroborated information.
- Avoid presenting the application as an official emergency-services channel.
- Include a concise disclaimer that the app does not replace local emergency services.

Do not imply that an AI-approved report guarantees factual authenticity or that emergency responders have received a notification.

## 16. Map and Incident Visual Language

Create a consistent visual language for incident types.

Suggested icon mapping:
- Fire: flame
- Accident: car collision or warning triangle
- Road blockage: road barrier
- Flooding: water or waves
- Public gathering: people or event marker
- General hazard: warning triangle

Use recognizable, accessible symbols and a restrained color system.

Urgency should be based on available report data and explicit backend rules, not arbitrary visual decoration.

Selected markers should be clearly highlighted. Overlapping incidents should cluster at lower zoom levels, and the selected incident should remain easy to identify.

Ensure that the map remains visually dominant, particularly when there are many reports.

## 17. Suggested Screen Deliverables

Create a coherent, high-fidelity mobile design prototype covering these screens and states:

1. Main map with nearby incidents.
2. Main map with no nearby incidents.
3. Main map with a selected incident and preview bottom sheet.
4. Full incident details.
5. Built-in camera interface.
6. Captured-photo preview.
7. Incident report form.
8. Submission progress and AI review.
9. Successful publication state.
10. Pending review and rejected report states.
11. Activity / My Reports screen.
12. Settings and radius preferences.
13. Nearby alert notification examples.
14. Location and camera permission-denied states.
15. Network failure and retry states.

Not every state requires a separate full-screen design if a realistic component state or interactive prototype can demonstrate it clearly.

## 18. Interaction and Prototype Requirements

Make the prototype interactive wherever possible.

Demonstrate this complete journey:

1. Open Inzar.
2. See incidents on the map.
3. Change the search radius.
4. Select an incident marker.
5. Open its details.
6. Return to the map.
7. Tap Report.
8. Capture a photo using the designed camera flow.
9. Select an incident category.
10. Enter a description.
11. Review or adjust the location.
12. Submit the report.
13. View upload and AI-review progress.
14. See the appropriate outcome.
15. Find the submission in Activity.

Use realistic sample incident data for the prototype, clearly treated as demonstration content.

Create reusable design components and consistent spacing, colors, typography, and iconography across all screens.

If the design environment supports it, use realistic map imagery or a map component rather than a generic illustrated background.

The prototype should feel like one cohesive application, not a set of unrelated mockups.

## 19. Technical Design Constraints

The intended platform is Android, with implementation in Kotlin and Jetpack Compose.

Therefore:
- Respect Android status bars, navigation bars, and system insets.
- Prefer native-feeling bottom sheets, dialogs, and controls.
- Avoid web-only interactions that would be awkward on a mobile device.
- Use a component-based design system suitable for Jetpack Compose.
- Keep navigation and UI state predictable.
- Avoid unnecessarily complex layouts and excessive nested surfaces.
- Treat the map and camera as performance-sensitive primary features.
- Do not assume specific backend endpoints, AI models, or map providers have already been selected.

Design the interface independently of backend implementation details while making all states realistic to implement.

## 20. Final Design Direction

The final result should feel like a fast, trustworthy, map-first utility that people can open, understand within seconds, and use without a tutorial.

The main map must be the hero. The report button must be obvious. Incident information must be easy to scan. The reporting workflow must be short. Verification states must be honest and understandable.

Prioritize excellent information hierarchy, compact layouts, responsive interactions, and practical implementation over visual effects.

Before finalizing, review the complete user journey and remove any screen, button, animation, or field that does not meaningfully improve safety, usability, trust, or reporting speed.

**Primary product principle: Capture quickly. Verify intelligently. Alert locally.**