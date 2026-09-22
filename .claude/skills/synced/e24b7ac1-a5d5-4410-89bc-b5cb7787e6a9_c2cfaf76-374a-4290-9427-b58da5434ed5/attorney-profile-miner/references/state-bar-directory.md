# State Bar Directory Reference

All 50 states + DC. For each state: lookup URL, governing body, available fields,
and any access notes (opt-out, form-based, login walls, etc.).

**Access types:**
- `REST` — Simple HTTP fetch works, returns structured or scrapeable HTML
- `FORM` — JavaScript-heavy; requires browser automation (Playwright/Puppeteer)
- `PHONE` — No online directory; phone only

---

## Alabama
- **Body:** Alabama State Bar
- **URL:** https://www.alabar.org/find-a-member/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM
- **Notes:** Member search by name or bar number

## Alaska
- **Body:** Alaska Bar Association
- **URL:** https://alaskabar.org/for-lawyers/member-directories/
- **Fields:** Name, firm, address, status
- **Access:** FORM
- **Notes:** Partial — some data members-only; bar # not always public

## Arizona
- **Body:** State Bar of Arizona
- **URL:** https://azbar.org/for-legal-professionals/practice-tools-management/member-directory/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Arkansas
- **Body:** Arkansas Judiciary (court system)
- **URL:** https://attorneyinfo.aoc.arkansas.gov/info/attorney_search/info/attorney/attorneysearch.aspx
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** Court-managed, not state bar

## California
- **Body:** State Bar of California
- **URL:** https://apps.calbar.ca.gov/attorney/LicenseeSearch/QuickSearch
- **Fields:** Name, bar #, firm, address, status, phone, email (sometimes), discipline
- **Access:** REST
- **Notes:** Most robust directory; includes discipline history; email present for ~40% of attorneys

## Colorado
- **Body:** CO Supreme Court — Office of Attorney Registration
- **URL:** https://www.coloradolegalregulation.com/attorney-search/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Connecticut
- **Body:** Connecticut Judicial Branch
- **URL:** https://www.jud.ct.gov/AttorneyFirmInquiry/
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST
- **Notes:** Can search by attorney name or firm name

## Delaware
- **Body:** Delaware Supreme Court
- **URL:** https://rp470541.doelegal.com/vwPublicSearch/Show-VwPublicSearch-Table.aspx
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## District of Columbia
- **Body:** DC Bar
- **URL:** https://my.dcbar.org/memberdirectory
- **Fields:** Name, bar #, firm, address, status, phone, email (sometimes)
- **Access:** FORM
- **Notes:** Includes discipline history

## Florida
- **Body:** The Florida Bar
- **URL:** https://www.floridabar.org/directories/find-mbr/
- **Fields:** Name, bar #, firm, address, status, phone, email, specialty
- **Access:** REST
- **Notes:** One of the most complete directories; email present for ~50% of attorneys

## Georgia
- **Body:** State Bar of Georgia
- **URL:** https://www.gabar.org/member-directory/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Hawaii
- **Body:** Hawaii State Bar Association
- **URL:** https://hsba.org/HSBA_2020/Public/Find_a_Lawyer.aspx
- **Fields:** Name, firm, address, status
- **Access:** FORM
- **Notes:** Bar # not always displayed publicly

## Idaho
- **Body:** Idaho State Bar
- **URL:** https://isb.idaho.gov/licensing-mcle/attorney-roster-search/
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST

## Illinois
- **Body:** ARDC — Supreme Court of Illinois
- **URL:** https://www.iardc.org/Lawyer/Search
- **Fields:** Name, ARDC #, firm, address, status, phone, discipline
- **Access:** REST
- **Notes:** ARDC registration number (not called "bar number"); very complete

## Indiana
- **Body:** Indiana Judicial Branch
- **URL:** https://courtapps.in.gov/rollofattorneys/search
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** Court-managed Roll of Attorneys

## Iowa
- **Body:** Iowa Judicial Branch
- **URL:** https://www.iacourtcommissions.org/ords/f?p=106:10
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## Kansas
- **Body:** Kansas Supreme Court — KARD
- **URL:** https://directory-kard.kscourts.gov/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** REST

## Kentucky
- **Body:** Kentucky Bar Association
- **URL:** https://kybar.org/For-Public/Find-a-Lawyer
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## Louisiana
- **Body:** Louisiana State Bar Association
- **URL:** https://www.lsba.org/MD321654/MembershipDirectory.aspx
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Maine
- **Body:** Maine Board of Overseers of the Bar
- **URL:** https://apps.web.maine.gov/cgi-bin/online/maine_bar/attorney_directory.pl
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST

## Maryland
- **Body:** Maryland Courts
- **URL:** https://www.courts.state.md.us/attysearch
- **Fields:** Name, bar #, firm, address, status, discipline
- **Access:** FORM
- **Notes:** Court-managed

## Massachusetts
- **Body:** MA Board of Bar Overseers
- **URL:** https://www.massbbo.org/s/
- **Fields:** Name, BBO #, firm, address, status
- **Access:** FORM
- **Notes:** BBO# is the identifier (not called "bar number" in UI)

## Michigan
- **Body:** State Bar of Michigan
- **URL:** https://www.michbar.org/memberdirectory/home
- **Fields:** Name, bar #, firm, address, status, phone, email (sometimes)
- **Access:** FORM

## Minnesota
- **Body:** MN Judicial Branch — LPRB
- **URL:** https://lprb.mncourts.gov/LawyerSearch/Pages/default.aspx
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** Court-managed Lawyer Registration

## Mississippi
- **Body:** The Mississippi Bar
- **URL:** https://msbar.reliaguide.com/home
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## Missouri
- **Body:** The Missouri Bar
- **URL:** https://mobar.org/site/For_the_Public/Official_Directory_of_Lawyers/site/content/For-the-Public/Lawyer_Directory.aspx
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Montana
- **Body:** State Bar of Montana
- **URL:** https://www.montanabar.org/For-Attorneys/Attorney-Directory
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## Nebraska
- **Body:** Nebraska State Bar Association
- **URL:** https://www.nebar.com/search/custom.asp?id=2319
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Nevada
- **Body:** State Bar of Nevada
- **URL:** https://nvbar.org/for-the-public/find-a-lawyer/
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## New Hampshire
- **Body:** NH Bar Association
- **URL:** https://www.nhbar.org/attorney-verification-good-standing-request
- **Fields:** Name, bar #, address, status
- **Access:** FORM
- **Notes:** Verification-focused; limited fields exposed

## New Jersey
- **Body:** NJ Courts (Judiciary)
- **URL:** https://portalattysearch-cloud.njcourts.gov/prweb/PRServletPublicAuth/app/Attorney/-amRUHgepTwWWiiBQpI9_yQNuum4oN16*/!STANDARD?AppName=AttorneySearch
- **Fields:** Name, bar ID, firm, address, status, admission date
- **Access:** FORM
- **Notes:** Fully online as of ~2023; formerly phone-only

## New Mexico
- **Body:** State Bar of New Mexico
- **URL:** https://www.sbnm.org/For-Public/I-Need-a-Lawyer/Online-Bar-Directory
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## New York
- **Body:** NY Unified Court System
- **URL:** https://iapps.courts.state.ny.us/attorneyservices/search?0
- **Fields:** Name, registration #, firm, address, status, admission date
- **Access:** REST
- **Notes:** Court system — uses "registration number" not "bar number"; email sometimes present

## North Carolina
- **Body:** North Carolina State Bar
- **URL:** https://portal.ncbar.gov/verification/search.aspx
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## North Dakota
- **Body:** ND Court System
- **URL:** https://www.ndcourts.gov/lawyers
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST
- **Notes:** Court-managed

## Ohio
- **Body:** Supreme Court of Ohio
- **URL:** https://www.supremecourt.ohio.gov/attorneysearch/#/search
- **Fields:** Name, registration #, firm, address, status, phone
- **Access:** REST
- **Notes:** Uses "attorney registration number"

## Oklahoma
- **Body:** Oklahoma Bar Association
- **URL:** https://www.okbar.org/findalawyer/
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** OPT-OUT STATE — attorneys in good standing can opt out. If not found, call 405-416-7000

## Oregon
- **Body:** Oregon State Bar
- **URL:** https://www.osbar.org/members/membersearch_start.asp
- **Fields:** Name, bar #, firm, address, status, phone, email (sometimes)
- **Access:** REST

## Pennsylvania
- **Body:** Disciplinary Board — PA Supreme Court
- **URL:** https://www.padisciplinaryboard.org/for-the-public/find-attorney
- **Fields:** Name, bar #, firm, address, status, phone, discipline
- **Access:** REST
- **Notes:** Includes full discipline history

## Rhode Island
- **Body:** Rhode Island Judiciary
- **URL:** http://rijrs.courts.ri.gov/rijrs/attorney.do
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** Court-managed; note http (not https)

## South Carolina
- **Body:** SC Courts
- **URL:** https://www.sccourts.org/attorneys/
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** Court system directory

## South Dakota
- **Body:** State Bar of South Dakota
- **URL:** N/A — no online directory
- **Fields:** None available online
- **Access:** PHONE — 800-952-2333
- **Notes:** Skip Tier A entirely. Go to firm website (Tier B) and flag status as unverified.

## Tennessee
- **Body:** Board of Professional Responsibility — TN Supreme Court
- **URL:** https://www.tbpr.org/for-the-public/online-attorney-directory
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST

## Texas
- **Body:** State Bar of Texas
- **URL:** https://www.texasbar.com/AM/Template.cfm?Section=Find_A_Lawyer
- **Fields:** Name, bar #, firm, address, status, phone, email (sometimes), practice areas, license date
- **Access:** REST
- **Notes:** One of the most complete; email present for ~35% of attorneys

## Utah
- **Body:** Utah State Bar
- **URL:** https://services.utahbar.org/Member-Services/Public/Attorney-Search
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## Vermont
- **Body:** Professional Conduct Board — VT Supreme Court
- **URL:** https://www.vermontjudiciary.org/attorneys/attorney-licensing
- **Fields:** Name, bar #, address, status
- **Access:** REST
- **Notes:** Firm name not always shown; alphabetical licensed attorney list

## Virginia
- **Body:** Virginia State Bar
- **URL:** https://www.vsb.org/site/public/attorney-search
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM
- **Notes:** OPT-OUT STATE — attorneys in good standing can opt out. If not found, call 804-775-0500

## Washington
- **Body:** WA State Bar Association
- **URL:** https://www.wsba.org/for-the-public/find-a-lawyer
- **Fields:** Name, bar #, firm, address, status, phone
- **Access:** FORM

## West Virginia
- **Body:** WV Office of Disciplinary Counsel
- **URL:** https://wvlawyerdiscipline.org/member-directory-search/
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

## Wisconsin
- **Body:** Wisconsin Office of Lawyer Regulation
- **URL:** https://www.wicourts.gov/services/attorney/attysearch.htm
- **Fields:** Name, bar #, firm, address, status
- **Access:** REST
- **Notes:** Court-managed

## Wyoming
- **Body:** Wyoming State Bar
- **URL:** https://wyomingbar.org/for-the-public/find-a-lawyer/
- **Fields:** Name, bar #, firm, address, status
- **Access:** FORM

---

## States where email appears in bar registry (~30% of cases)

High likelihood of finding email directly in Tier A:
- California (~40%)
- Florida (~50%)
- Texas (~35%)
- New York (~20%)
- Oregon (~30%)
- Michigan (~25%)
- DC (~30%)

For all others, expect to proceed to Tier B (firm website).

---

## States with REST access (simple HTTP fetch works)

CA, CT, ID, IL, KS, ME, ND, NY, OH, OR, PA, TN, TX, VT, WI

For all other states, browser automation (Playwright/Puppeteer) is needed to
interact with form-based search pages.
