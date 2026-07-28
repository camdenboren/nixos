import csv

VULNS_FILE = "vulns.csv"

cves = []
cve_scores = []
critical_vulns = []
categories = {
    "Total": 0,
    "Critical": 0,
    "High": 0,
    "Medium": 0,
    "Low": 0,
}


# formatting for count and critical_vulns printing
# we just estimate `cat`, `count`, and `cve_score` since they're pretty predictable
PADDING = 2
print_lens = {
    "cat": 8,
    "count": 5,
    "pkg": 0,
    "ver": 0,
    "cve": 0,
    "cve_score": len("Score"),
    "link": 0,
}


def format_entry(entry, print_len):
    return entry + (print_len - len(entry)) * " "


# read cves from outputted CSV
# i reduce false-positives by only including vulns reported by multiple scanners
# (i.e., sum > 1)
with open(VULNS_FILE, "r") as f:
    data = csv.reader(f)
    _fields = next(data)

    for row in data:
        sum = int(row[8])
        if sum > 1:
            cves.append(row)

# identify maximum length of each critical_vulns field (for formatting purposes)
for row in cves:
    cve_score = 0
    if row[4] != "":
        cve_score = float(row[4])

    if cve_score >= 9:
        print_lens["cve"] = max(len(row[0]), print_lens["cve"])
        print_lens["link"] = max(len(row[1]), print_lens["link"])
        print_lens["pkg"] = max(len(row[2]), print_lens["pkg"])
        print_lens["ver"] = max(max(len(row[3]), print_lens["ver"]), len("Version"))

# generate list of cve_scores and format critical vulnerabilities for printing
for row in cves:
    cve = row[0]
    link = row[1]
    pkg = row[2]
    ver = row[3]
    cve_score = 0
    if row[4] != "":
        cve_score = float(row[4])
    sum = int(row[8])

    cve_scores.append(cve_score)

    # add formatted critical vulns to list for printing
    if cve_score >= 9.0:
        critical_vulns.append(
            f"| {format_entry(pkg, print_lens['pkg'])}"
            + f" | {format_entry(ver, print_lens['ver'])}"
            + f" | {format_entry(cve, print_lens['cve'])}"
            + f" | {format_entry(str(cve_score), print_lens['cve_score'])}"
            + f" | {format_entry(link, print_lens['link'])} |"
        )

# count the number of vulnerabilities in each category
for cve_score in cve_scores:
    categories["Total"] += 1
    if cve_score >= 9.0:
        categories["Critical"] += 1
    elif cve_score >= 7.0:
        categories["High"] += 1
    elif cve_score >= 4.0:
        categories["Medium"] += 1
    else:
        categories["Low"] += 1

# prepare the table separators
totals_sep = (
    "|"
    + (print_lens["cat"] + PADDING) * "-"
    + "|"
    + (print_lens["count"] + PADDING) * "-"
    + "|"
)
crit_vuln_sep = "|"
for item in print_lens:
    if item != "cat" and item != "count":
        crit_vuln_sep += (print_lens[item] + PADDING) * "-" + "|"

# print markdown-friendly results
print("# Vulnxscan Results\n")
print("## Vulnerability Counts\n")
print(
    f"| {format_entry('Category', print_lens['cat'])}"
    + f" | {format_entry('Count', print_lens['count'])} |"
)
print(totals_sep)
for cat in categories:
    print(
        f"| {format_entry(cat, print_lens['cat'])}"
        + f" | {format_entry(str(categories[cat]), print_lens['count'])} |"
    )
print("\n")

print("## Critical Vulnerabilities\n")
print(
    f"| {format_entry('Package', print_lens['pkg'])}"
    + f" | {format_entry('Version', print_lens['ver'])}"
    + f" | {format_entry('CVE', print_lens['cve'])}"
    + f" | {format_entry('Score', print_lens['cve_score'])}"
    + f" | {format_entry('Link', print_lens['link'])} |"
)
print(crit_vuln_sep)
for vuln in critical_vulns:
    print(vuln)
