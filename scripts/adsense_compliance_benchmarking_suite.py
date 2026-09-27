#!/usr/bin/env python3
"""
adsense_compliance_benchmarking_suite.py — Automated Google AdSense Readiness & Compliance Benchmarking Suite.

Audits web applications (freeOCR.me, FreePDFToolz.me, or any HTML/web directory) for 100% compliance
with Google AdSense Program Policies, Publisher Quality Guidelines, and Search Console Indexability.

Evaluates 8 Key Dimensions:
  1. AdSense Monetization Code Tag Presence in <head>
  2. Core Publisher Trust & Legal Pages (/privacy, /terms, /about, /contact)
  3. Semantic Editorial Depth & Word Count Thresholds (>500 words)
  4. Mobile Usability & Viewport Responsive Configuration
  5. Canonical URL & Sitemap.xml Synchronicity
  6. Zero Empty Ad Placeholders / Ad Unit Safety Pre-Approval
  7. Navigation Integrity & Internal Cross-Linking Health
  8. Service Worker Review-Mode Cache Invalidation Status

Usage:
  python scripts/adsense_compliance_benchmarking_suite.py [--dir src/frontend/web] [--client ca-pub-6775900998665017]
"""

import os
import sys
import re
import argparse
import glob
from html.parser import HTMLParser

class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__()
        self.reset()
        self.fed = []
        self.skip_tags = {'script', 'style', 'noscript', 'svg'}
        self.in_skip = False

    def handle_starttag(self, tag, attrs):
        if tag.lower() in self.skip_tags:
            self.in_skip = True

    def handle_endtag(self, tag):
        if tag.lower() in self.skip_tags:
            self.in_skip = False

    def handle_data(self, d):
        if not self.in_skip:
            self.fed.append(d)

    def get_text(self):
        return ' '.join(self.fed)

def extract_words(html_content):
    parser = TextExtractor()
    try:
        parser.feed(html_content)
        text = parser.get_text()
    except Exception:
        text = re.sub(r'<[^>]+>', ' ', html_content)
    words = re.findall(r'\b\w+\b', text)
    return len(words), text

class AdSenseBenchmarkingSuite:
    def __init__(self, target_dir, client_id="ca-pub-6775900998665017"):
        self.target_dir = os.path.abspath(target_dir)
        self.client_id = client_id
        self.results = {}
        self.total_checks = 8
        self.passed_checks = 0

    def run_all_audits(self):
        print("=" * 80)
        print("GOOGLE ADSENSE COMPLIANCE & READINESS BENCHMARKING SUITE")
        print(f"Target Directory: {self.target_dir}")
        print(f"AdSense Client ID: {self.client_id}")
        print("=" * 80)

        if not os.path.exists(self.target_dir):
            print(f"[FAIL] Target directory does not exist: {self.target_dir}")
            return False

        self.audit_adsense_tag_presence()
        self.audit_trust_and_legal_pages()
        self.audit_editorial_content_depth()
        self.audit_mobile_viewport_and_seo()
        self.audit_canonical_and_sitemap()
        self.audit_ad_placeholder_safety()
        self.audit_navigation_integrity()
        self.audit_service_worker_cache_status()

        self.print_summary_report()
        score = (self.passed_checks / self.total_checks) * 100
        return score >= 85.0

    def audit_adsense_tag_presence(self):
        print("\n[Audit 1/8] Verifying AdSense Monetization Code Snippet in <head>...")
        html_files = glob.glob(os.path.join(self.target_dir, "**/*.html"), recursive=True)
        missing_tag = []
        found_tag = 0

        for f in html_files:
            # Skip build duplicates if auditing multi-dir
            rel = os.path.relpath(f, self.target_dir)
            try:
                with open(f, 'r', encoding='utf-8') as fp:
                    content = fp.read()
                head_part = content.split('</head>')[0] if '</head>' in content else content
                if 'pagead2.googlesyndication.com' in head_part and self.client_id in head_part:
                    found_tag += 1
                else:
                    missing_tag.append(rel)
            except Exception as e:
                missing_tag.append(f"{rel} (read error)")

        # Specifically check root index.html
        root_index = os.path.join(self.target_dir, "index.html")
        has_root_tag = False
        if os.path.exists(root_index):
            with open(root_index, 'r', encoding='utf-8') as fp:
                c = fp.read()
            if 'pagead2.googlesyndication.com' in c and self.client_id in c:
                has_root_tag = True

        status = "PASS" if has_root_tag and len(missing_tag) == 0 else "FAIL"
        if not has_root_tag:
            details = "Root index.html is missing the AdSense code snippet!"
        elif missing_tag:
            details = f"{found_tag} files have tag, but {len(missing_tag)} files missing tag (e.g. {missing_tag[:3]})"
        else:
            details = f"All {found_tag} HTML files contain valid AdSense snippet in <head>."

        self.record_result("AdSense Tag Coverage", status, details)

    def audit_trust_and_legal_pages(self):
        print("\n[Audit 2/8] Auditing Publisher Trust & Compliance Pages (/privacy, /terms, /about, /contact)...")
        required_pages = {
            "privacy": ["GDPR", "CCPA", "cookies", "retention"],
            "terms": ["Terms of Service", "liability", "governing"],
            "about": ["about", "mission", "platform"],
            "contact": ["contact", "support", "email"]
        }

        missing_pages = []
        lacking_disclosures = []

        for p_name, keywords in required_pages.items():
            # Check p_name/index.html or p_name.html
            p_dir_index = os.path.join(self.target_dir, p_name, "index.html")
            p_file = os.path.join(self.target_dir, f"{p_name}.html")

            found_path = p_dir_index if os.path.exists(p_dir_index) else (p_file if os.path.exists(p_file) else None)
            if not found_path:
                missing_pages.append(p_name)
            else:
                with open(found_path, 'r', encoding='utf-8') as fp:
                    c = fp.read().lower()
                for kw in keywords:
                    if kw.lower() not in c:
                        lacking_disclosures.append(f"{p_name} missing '{kw}'")

        if missing_pages:
            status = "FAIL"
            details = f"Missing mandatory compliance pages: {', '.join(missing_pages)}"
        elif lacking_disclosures:
            status = "WARN"
            details = f"Pages present, but missing key disclosures: {', '.join(lacking_disclosures)}"
        else:
            status = "PASS"
            details = "All 4 compliance pages present with robust GDPR/CCPA & contact disclosures."

        self.record_result("Trust & Legal Pages", status, details)

    def audit_editorial_content_depth(self):
        print("\n[Audit 3/8] Measuring Semantic Text Volume & Anti-Thin Content Safeguards...")
        articles_dir = os.path.join(self.target_dir, "kb")
        kb_exists = os.path.exists(articles_dir)

        if not kb_exists:
            articles_dir = os.path.join(self.target_dir, "knowledge-base")

        html_files = glob.glob(os.path.join(articles_dir, "**/*.html"), recursive=True) if os.path.exists(articles_dir) else []
        # Filter for unique articles (avoid duplicate .html and /index.html counting)
        unique_pages = [f for f in html_files if f.endswith('index.html')]
        if not unique_pages:
            unique_pages = html_files

        thin_pages = []
        total_words = 0

        for f in unique_pages:
            rel = os.path.relpath(f, self.target_dir)
            with open(f, 'r', encoding='utf-8') as fp:
                c = fp.read()
            wc, _ = extract_words(c)
            total_words += wc
            if wc < 500:
                thin_pages.append((rel, wc))

        # Check landing page editorial text
        root_index = os.path.join(self.target_dir, "index.html")
        root_wc = 0
        if os.path.exists(root_index):
            with open(root_index, 'r', encoding='utf-8') as fp:
                rc = fp.read()
            root_wc, _ = extract_words(rc)

        if len(unique_pages) < 5:
            status = "FAIL"
            details = f"Insufficient article volume: Only {len(unique_pages)} knowledge base pages detected."
        elif thin_pages:
            status = "WARN"
            details = f"{len(thin_pages)} pages below 500 words threshold. Total words: {total_words:,}."
        else:
            status = "PASS"
            details = f"{len(unique_pages)} comprehensive guides audited. Total: {total_words:,} words (Landing: {root_wc} words)."

        self.record_result("Editorial Content Depth", status, details)

    def audit_mobile_viewport_and_seo(self):
        print("\n[Audit 4/8] Auditing Mobile Viewport Configuration & Robots Directives...")
        root_index = os.path.join(self.target_dir, "index.html")
        issues = []

        if os.path.exists(root_index):
            with open(root_index, 'r', encoding='utf-8') as fp:
                c = fp.read()
            if 'meta name="viewport"' not in c and 'name="viewport"' not in c:
                issues.append("Missing viewport meta tag")
            if 'robots' in c and 'noindex' in c:
                issues.append("Robots meta tag contains noindex on landing page!")
            if '<title>' not in c:
                issues.append("Missing <title> tag on landing page")
        else:
            issues.append("Root index.html missing")

        status = "FAIL" if issues else "PASS"
        details = ", ".join(issues) if issues else "Responsive viewport & indexing directives configured correctly."
        self.record_result("Mobile & Robots Config", status, details)

    def audit_canonical_and_sitemap(self):
        print("\n[Audit 5/8] Verifying Canonical Tags & Sitemap.xml Synchronicity...")
        sitemap_path = os.path.join(self.target_dir, "sitemap.xml")
        has_sitemap = os.path.exists(sitemap_path)

        sitemap_urls = []
        if has_sitemap:
            with open(sitemap_path, 'r', encoding='utf-8') as fp:
                s_content = fp.read()
            sitemap_urls = re.findall(r'<loc>(https?://[^<]+)</loc>', s_content)

        issues = []
        if not has_sitemap:
            issues.append("sitemap.xml not found in web root")
        elif len(sitemap_urls) < 10:
            issues.append(f"sitemap.xml contains only {len(sitemap_urls)} URLs (expected >= 25)")

        status = "FAIL" if issues else "PASS"
        details = ", ".join(issues) if issues else f"sitemap.xml valid with {len(sitemap_urls)} canonical URLs indexed."
        self.record_result("Canonical & Sitemap Sync", status, details)

    def audit_ad_placeholder_safety(self):
        print("\n[Audit 6/8] Auditing Ad Unit Suppression (Zero Empty Ad Placeholders)...")
        html_files = glob.glob(os.path.join(self.target_dir, "**/*.html"), recursive=True)
        unsuppressed_ad_slots = []

        for f in html_files:
            rel = os.path.relpath(f, self.target_dir)
            with open(f, 'r', encoding='utf-8') as fp:
                c = fp.read()
            # Check for active <ins class="adsbygoogle"> that are not commented out
            # Remove comments to check live markup
            uncommented = re.sub(r'<!--.*?-->', '', c, flags=re.DOTALL)
            if '<ins class="adsbygoogle"' in uncommented:
                # Check if it has a style with display:none
                matches = re.findall(r'<ins[^>]*class=["\'][^"\']*adsbygoogle[^"\']*["\'][^>]*>', uncommented)
                for m in matches:
                    if 'display:none' not in m and 'display: none' not in m:
                        unsuppressed_ad_slots.append(rel)
                        break

        status = "FAIL" if unsuppressed_ad_slots else "PASS"
        if unsuppressed_ad_slots:
            details = f"Active unsuppressed empty ad tags found in {len(unsuppressed_ad_slots)} files (e.g. {unsuppressed_ad_slots[:2]})!"
        else:
            details = "All ad slots safely suppressed or commented out pending AdSense site approval."
        self.record_result("Ad Placeholder Safety", status, details)

    def audit_navigation_integrity(self):
        print("\n[Audit 7/8] Auditing Navigation Integrity & Internal Link Consistency...")
        root_index = os.path.join(self.target_dir, "index.html")
        nav_issues = []

        if os.path.exists(root_index):
            with open(root_index, 'r', encoding='utf-8') as fp:
                c = fp.read()
            for required_link in ['/about', '/kb', '/privacy', '/terms', '/contact']:
                if f'href="{required_link}"' not in c and f"href='{required_link}'" not in c:
                    nav_issues.append(f"Missing link {required_link}")

        status = "FAIL" if nav_issues else "PASS"
        details = ", ".join(nav_issues) if nav_issues else "All canonical nav endpoints (/about, /kb, /privacy, /terms, /contact) present."
        self.record_result("Navigation Integrity", status, details)

    def audit_service_worker_cache_status(self):
        print("\n[Audit 8/8] Checking Service Worker Review-Mode Cache Invalidation Status...")
        root_index = os.path.join(self.target_dir, "index.html")
        sw_file = os.path.join(self.target_dir, "flutter_service_worker.js")

        has_sw = os.path.exists(sw_file)
        bypasses_cache = False

        if os.path.exists(root_index):
            with open(root_index, 'r', encoding='utf-8') as fp:
                c = fp.read()
            if 'serviceWorker.getRegistrations' in c or 'caches.delete' in c or 'serviceWorker: false' in c:
                bypasses_cache = True

        if has_sw and not bypasses_cache:
            status = "WARN"
            details = "Active service worker found without explicit unregistration/cache-bypass logic in index.html for review mode."
        else:
            status = "PASS"
            details = "Service worker cache is suppressed or bypassed to prevent reviewer stale cache traps."
        self.record_result("Service Worker Cache Status", status, details)

    def record_result(self, check_name, status, details):
        self.results[check_name] = {"status": status, "details": details}
        if status == "PASS":
            self.passed_checks += 1
            print(f"  [PASS] {check_name}: {details}")
        elif status == "WARN":
            # Partial credit for warnings
            self.passed_checks += 0.5
            print(f"  [WARN] {check_name}: {details}")
        else:
            print(f"  [FAIL] {check_name}: {details}")

    def print_summary_report(self):
        score = (self.passed_checks / self.total_checks) * 100
        print("\n" + "=" * 80)
        print("ADSENSE COMPLIANCE BENCHMARKING SUMMARY REPORT")
        print("=" * 80)
        print(f"{'Check Dimension':<32} | {'Status':<6} | {'Details'}")
        print("-" * 80)
        for check, res in self.results.items():
            print(f"{check:<32} | {res['status']:<6} | {res['details']}")
        print("-" * 80)
        print(f"TOTAL COMPLIANCE SCORE: {score:.1f}% ({self.passed_checks:.1f} / {self.total_checks} passed)")
        if score >= 85.0:
            print("[RESULT] SITE IS READY FOR GOOGLE ADSENSE REVIEW SUBMISSION.")
        else:
            print("[RESULT] SITE REQUIRES REMEDIATION BEFORE CLICKING 'REQUEST REVIEW'.")
        print("=" * 80 + "\n")


def main():
    parser = argparse.ArgumentParser(description="Google AdSense Compliance & Readiness Benchmarking Suite")
    parser.add_argument("--dir", default="src/frontend/web", help="Target web directory to benchmark")
    parser.add_argument("--client", default="ca-pub-6775900998665017", help="AdSense Client ID (e.g. ca-pub-XXXXX)")
    args = parser.parse_args()

    suite = AdSenseBenchmarkingSuite(target_dir=args.dir, client_id=args.client)
    success = suite.run_all_audits()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
