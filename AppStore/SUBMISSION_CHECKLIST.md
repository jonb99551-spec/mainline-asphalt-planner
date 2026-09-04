# App Store Submission Checklist

Last prep pass: **September 4, 2026**

## Developer account (manual — App Store Connect + apple.com)

- [ ] Enroll in the Apple Developer Program ($99/yr).
- [ ] Complete Agreements, Tax, and Banking in App Store Connect.
- [ ] Consider enrolling in the App Store Small Business Program (reduces commission from 30% to 15%).
- [ ] Generate an App Store Connect API key (Users and Access → Integrations) if you want CLI uploads.

## Assets (all done in this prep pass)

- [x] App icon: `Mainline/Assets.xcassets/AppIcon.appiconset/AppIcon.png` — 1024×1024, sRGB, no alpha ✅
- [x] `Info.plist` privacy manifest: `Mainline/PrivacyInfo.xcprivacy` — tracking off, no data collected, no accessed API types
- [x] Store listing copy: `AppStore/STORE_LISTING.md`
- [x] Privacy policy (public site): `docs/privacy.html`
- [x] Marketing / support site: `docs/index.html`
- [x] Privacy policy (bundled reference copy): `AppStore/PRIVACY_POLICY.html`
- [ ] iPhone screenshots — capture 5–6 from a 6.9" simulator (iPhone 17 Pro Max) after entering a realistic job. Save under `AppStore/screenshots/`. Blocked in this pass by macOS Full Disk Access on the shell used for automation; press ⌘R in Xcode and use `File → Save Screen` in Simulator, or run `xcrun simctl io booted screenshot`.

## Hosting (manual — GitHub)

- [ ] Create a public repo `mainline-asphalt-planner` under your GitHub account.
- [ ] Push this project (or at minimum the `docs/` folder) to it.
- [ ] In the repo Settings → Pages, set Source = `main` branch, Folder = `/docs`.
- [ ] Confirm the two URLs return 200:
  - `https://<your-username>.github.io/mainline-asphalt-planner/`
  - `https://<your-username>.github.io/mainline-asphalt-planner/privacy.html`
- [ ] If your username is not `jonb99551-spec`, update the URLs in `AppStore/STORE_LISTING.md` before submitting.

## Xcode

- [ ] Open `Mainline.xcodeproj` and select your Apple Developer team under Signing & Capabilities (currently `L6YS63G3G6` in `project.yml`).
- [x] Bundle ID: `com.mainlineasphalt.planner`.
- [ ] Test ascending and descending jobs on a physical iPhone.
- [ ] Test large text, dark mode, VoiceOver, sharing, saving, editing, and deletion.
- [ ] Confirm version/build (currently 1.0 / 1).
- [ ] Product → Archive → Validate App → Distribute App → App Store Connect.

## App Store Connect record

- [ ] Reserve "Mainline Asphalt Planner" (My Apps → +).
- [ ] Paste listing copy from `AppStore/STORE_LISTING.md`.
- [ ] Set price tier to USD $9.99.
- [ ] Upload iPhone screenshots.
- [ ] Enter privacy-policy URL (hosted `privacy.html`).
- [ ] Enter support URL and marketing URL (hosted `index.html`).
- [ ] Answer app-privacy questionnaire — all "Data Not Collected".
- [ ] Age rating: expect 4+ (no restricted content).
- [ ] Export compliance: uses no encryption beyond iOS defaults — `ITSAppUsesNonExemptEncryption = NO` is already set in `project.yml`.
- [ ] Select the uploaded build and Submit for Review.

## Recommended release path

- [ ] TestFlight first with 3–5 paving pros for a week.
- [ ] Manual release after approval so you control launch timing.
