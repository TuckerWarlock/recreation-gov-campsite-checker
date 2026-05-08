# Campsite Availability Scraping

Check https://recreation.gov for campsite availability and get notified when sites open up.

> **Note:** Please don't abuse this script. Most folks out there don't know how to run scrapers against websites, so you're at an unfair advantage by using this.

## Quick Start

**1. One-time setup** (installs everything you need):
```bash
./setup.sh
```

**2. Edit your config** — `setup.sh` creates `camping.cfg` from the example. Open it and fill in your details:
```
START_DATE=2026-07-23
END_DATE=2026-07-28
PARKS=10083567        # White Wolf only — leave blank for all 15 Yosemite campgrounds

# Push notifications via ntfy.sh (free, recommended)
NTFY_TOPIC=unique-topic-name

# Email notifications via Gmail (optional)
EMAIL_ADDRESS=you@gmail.com
EMAIL_PASSWORD=xxxx xxxx xxxx xxxx
NOTIFY_EMAIL=you@example.com
```

**3. (Optional) Set up push notifications on your phone** — install the [ntfy app](https://ntfy.sh) and subscribe to the topic name from your config. That's it — no account needed.

**4. Check availability** (reads everything from `camping.cfg`):
```bash
./check.sh
```

**5. (Optional) Enable macOS pop-up notifications:**
```bash
brew install terminal-notifier
```
`setup.sh` will detect it automatically — no other configuration needed.

**6. Run it automatically every 5 minutes** so you get notified the moment a site opens up.

Open your crontab editor:
```bash
crontab -e
```
Add this line (`setup.sh` prints the exact command with your full path already filled in):
```
*/5 * * * * /path/to/recreation-gov-campsite-checker/check.sh >> /path/to/recreation-gov-campsite-checker/camping.log 2>&1
```
> ⚠️ **Mac sleep**: cron won't run while your Mac is asleep, so keep it plugged in or awake if you're watching for last-minute openings.

## Finding Park and Campsite IDs

**Park ID:** Go to https://recreation.gov and search for a campground. The URL will look like `https://www.recreation.gov/camping/campgrounds/232449` — that number is the park ID.

**Campsite ID:** Navigate to a specific campsite within a campground. The URL will look like `https://www.recreation.gov/camping/campsites/18621` — that number is the campsite ID.

You can also browse park IDs at https://pastudan.github.io/national-parks/.

## Usage Examples

Check multiple parks at once:
```
$ ./check.sh --start-date 2025-07-20 --end-date 2025-07-23 --parks 232448 232450 232447 232770
❌ TUOLUMNE MEADOWS: 0 site(s) available out of 148 site(s)
🏕 LOWER PINES: 11 site(s) available out of 73 site(s)
❌ UPPER PINES: 0 site(s) available out of 235 site(s)
❌ BASIN MONTANA CAMPGROUND: 0 site(s) available out of 30 site(s)
```

Show which specific sites are available and on what dates (`--show-campsite-info`):
```
$ ./check.sh --start-date 2025-07-20 --end-date 2025-07-23 --parks 232431 --show-campsite-info --nights 1
There are campsites available from 2025-07-20 to 2025-07-23!!!
🏕 ELK CREEK CAMPGROUND (SAWTOOTH NF) (232042): 1 site(s) available out of 1 site(s)
  * Site 69800 is available on the following dates:
    * 2025-07-20 -> 2025-07-21
    * 2025-07-21 -> 2025-07-22
```

Search for any 5 consecutive nights within a date range (`--nights`):
```
$ ./check.sh --start-date 2025-06-01 --end-date 2025-06-30 --nights 5 --parks 234038
There are campsites available from 2025-06-01 to 2025-06-30!!!
🏕 CHISOS BASIN (BIG BEND) (234038): 13 site(s) available out of 62 site(s)
```

Check only weekends (`--weekends-only`):
```bash
./check.sh --start-date 2025-07-01 --end-date 2025-07-31 --parks 232449 --weekends-only
```

Check a specific campsite by ID (`--campsite-ids`):
```bash
./check.sh --start-date 2025-06-01 --end-date 2025-06-30 --nights 5 --parks 234038 --campsite-ids 6943
```

Exclude specific sites like group campsites (`--exclusion-file`). Create a file with one site ID per line:
```
./check.sh --start-date 2025-07-01 --end-date 2025-07-07 --parks 232449 --exclusion-file excluded.txt
```

Read park IDs from a file instead of the command line:
```bash
./check.sh --start-date 2025-07-01 --end-date 2025-07-07 --stdin < parks.txt
```

## Development

Requires Python 3.9+. Python 3.14 is recommended.

This code is formatted using `black` and `isort`:
```bash
black -l 80 camping.py
isort camping.py
```

### Running Tests

Tests run automatically via GitHub Actions on every push to `main` and on pull requests. To run them locally:
```bash
source venv/bin/activate
python -m unittest -v
```

All tests must pass before a pull request gets merged.

## Credits

- [bri-bri/yosemite-camping](https://github.com/bri-bri/yosemite-camping) — original version of this scraper
- [jameswnl/recreation-gov-campsite-checker](https://github.com/jameswnl/recreation-gov-campsite-checker) — upstream fork this repo is based on
- [streeter/recreation-gov-campsite-checker](https://github.com/streeter/recreation-gov-campsite-checker) — inspiration for the `terminal-notifier` macOS notification integration

