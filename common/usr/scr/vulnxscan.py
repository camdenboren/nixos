import csv
import sys

cve_scores = []
critical_vulns = []
categories = {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 0,
}


# formatting for count and crit vuln printing
def format_count(num):
    return str(num) + (3 - len(str(num))) * " " + " |"


print_len = {
    "pkg": 15,
    "ver": 10,
    "cve": 15,
    "cve_score": 4,
    "link": 47,
}
crit_vuln_sep = "+"
for item in print_len:
    crit_vuln_sep += (print_len[item] + 2) * "-" + "+"

data = csv.reader(sys.stdin)
fields = next(data)
for row in data:
    cve = row[0]
    link = row[1]
    pkg = row[2]
    ver = row[3]
    cve_score = 0
    if row[4] != "":
        cve_score = float(row[4])
    sum = int(row[8])

    # reduce false-positives by only including vulns reported by multiple scanners
    if sum > 1:
        cve_scores.append(cve_score)

        # add formatted critical vulns to list for printing
        if cve_score >= 9.0:
            pkg = pkg + (print_len["pkg"] - len(pkg)) * " "
            ver = ver + (print_len["ver"] - len(ver)) * " "
            cve = cve + (print_len["cve"] - len(cve)) * " "
            cve_score = (
                str(cve_score) + (print_len["cve_score"] - len(str(cve_score))) * " "
            )
            link = link + (print_len["link"] - len(link)) * " "
            critical_vulns.append(f"| {pkg} | {ver} | {cve} | {cve_score} | {link} |")

for cve_score in cve_scores:
    if cve_score >= 9.0:
        categories["critical"] += 1
    elif cve_score >= 7.0:
        categories["high"] += 1
    elif cve_score >= 4.0:
        categories["medium"] += 1
    else:
        categories["low"] += 1


print("Vulnerability Counts")
print("+----------+-----+")
print("| Total    | " + format_count(len(cve_scores)))
print("| Critical | " + format_count(categories["critical"]))
print("| High     | " + format_count(categories["high"]))
print("| Medium   | " + format_count(categories["medium"]))
print("| Low      | " + format_count(categories["low"]))
print("+----------+-----+\n")

print("Critical Vulnerabilities")
print(crit_vuln_sep)
for vuln in critical_vulns:
    print(vuln)
print(crit_vuln_sep)
