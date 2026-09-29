import os
import sys
import xml.etree.ElementTree as ET
from google.oauth2 import service_account
from googleapiclient.discovery import build

KEY_PATH = r"C:\Users\Ihtiram\.gemini\freeocr-staging-app_gsc_key.json"
SITEMAP_PATH = r"src\frontend\web\sitemap.xml"
SITE_URL = "sc-domain:freeocr.me"

def main():
    if not os.path.exists(KEY_PATH):
        print(f"Error: Key file not found at {KEY_PATH}")
        sys.exit(1)

    # 1. Parse Sitemap URLs
    tree = ET.parse(SITEMAP_PATH)
    root = tree.getroot()
    urls = []
    for loc in root.findall('.//{http://www.sitemaps.org/schemas/sitemap/0.9}loc'):
        urls.append(loc.text.strip())

    print(f"Loaded {len(urls)} URLs from {SITEMAP_PATH}")
    print(f"Authenticating with Google Search Console for {SITE_URL} ...\n")

    creds = service_account.Credentials.from_service_account_file(
        KEY_PATH, scopes=['https://www.googleapis.com/auth/webmasters.readonly']
    )
    service = build('searchconsole', 'v1', credentials=creds)

    print("=" * 110)
    print(f"{'URL':<48} | {'Verdict':<8} | {'Coverage State':<28} | {'Last Crawl Time'}")
    print("=" * 110)

    indexed_count = 0
    passed_count = 0
    crawl_issues = []

    for url in urls:
        short_url = url.replace("https://freeocr.me", "")
        if not short_url:
            short_url = "/"

        try:
            req = {
                'inspectionUrl': url,
                'siteUrl': SITE_URL
            }
            res = service.urlInspection().index().inspect(body=req).execute()
            result = res.get('inspectionResult', {})
            status_res = result.get('indexStatusResult', {})
            
            verdict = status_res.get('verdict', 'UNKNOWN')
            coverage = status_res.get('coverageState', 'Unknown')
            crawl_time = status_res.get('lastCrawlTime', 'Never')
            if crawl_time and len(crawl_time) > 19:
                crawl_time = crawl_time[:19].replace("T", " ")

            if verdict == 'PASS':
                passed_count += 1
            if 'indexed' in coverage.lower() and 'not indexed' not in coverage.lower():
                indexed_count += 1
            elif 'not indexed' in coverage.lower():
                crawl_issues.append((short_url, coverage))

            print(f"{short_url:<48} | {verdict:<8} | {coverage:<28} | {crawl_time}")
        except Exception as e:
            print(f"{short_url:<48} | {'ERROR':<8} | {str(e)[:28]} | -")

    print("=" * 110)
    print(f"Total Sitemaped URLs:   {len(urls)}")
    print(f"Live Indexed (Serving): {indexed_count} / {len(urls)} ({round(indexed_count / len(urls) * 100, 1)}%)")
    print(f"Verdict PASS:           {passed_count} / {len(urls)}")
    if crawl_issues:
        print("\nPending / Not Yet Indexed URLs:")
        for u, cov in crawl_issues:
            print(f"  - {u}: {cov}")
    print("=" * 110)

if __name__ == '__main__':
    main()
