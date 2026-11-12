use std::fs;
use std::process;

const VULNS_FILE: &str = "vulns.csv";
const PADDING: usize = 2;
const CRITICAL_SCORE: f64 = 9.0;
const HIGH_SCORE: f64 = 7.0;
const MEDIUM_SCORE: f64 = 4.0;
const SCANNERS: [&str; 3] = ["grype", "osv", "vulnix"];

struct Row {
    vuln_id: String,
    url: String,
    package: String,
    version: String,
    severity: f64,
}

#[derive(Default)]
struct Widths {
    cat: usize,
    count: usize,
    pkg: usize,
    ver: usize,
    cve: usize,
    score: usize,
    link: usize,
}

fn main() {
    if let Err(error) = run() {
        eprintln!("vulnxscan: {error}");
        process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let input = fs::read_to_string(VULNS_FILE)
        .map_err(|error| format!("failed to read {VULNS_FILE}: {error}"))?;
    print!("{}", render(&load_rows(&input)?));
    Ok(())
}

// minimal CSV reader: handles quoted fields, escaped quotes, and CRLF line endings
fn parse_csv(input: &str) -> Result<Vec<Vec<String>>, String> {
    let mut records = Vec::new();
    let mut record = Vec::new();
    let mut field = String::new();
    let mut in_quotes = false;
    let mut chars = input.chars().peekable();

    while let Some(ch) = chars.next() {
        if in_quotes {
            if ch == '"' {
                if chars.peek() == Some(&'"') {
                    chars.next();
                    field.push('"');
                } else {
                    in_quotes = false;
                }
            } else {
                field.push(ch);
            }
            continue;
        }

        match ch {
            '"' if field.is_empty() => in_quotes = true,
            ',' => record.push(std::mem::take(&mut field)),
            '\n' => {
                record.push(std::mem::take(&mut field));
                records.push(std::mem::take(&mut record));
            }
            '\r' => {
                if chars.peek() == Some(&'\n') {
                    chars.next();
                }
                record.push(std::mem::take(&mut field));
                records.push(std::mem::take(&mut record));
            }
            _ => field.push(ch),
        }
    }

    if in_quotes {
        return Err("unterminated quoted field".to_string());
    }
    if !field.is_empty() || !record.is_empty() {
        record.push(field);
        records.push(record);
    }

    Ok(records)
}

fn field(record: &[String], index: usize) -> &str {
    record.get(index).map_or("", String::as_str)
}

// missing or invalid numeric fields fall back to zero
fn number(record: &[String], index: usize) -> f64 {
    field(record, index).trim().parse().unwrap_or(0.0)
}

// match headers case-insensitively; aliases keep older reports working
fn column(header: &[String], names: &[&str]) -> Result<usize, String> {
    header
        .iter()
        .position(|column| names.iter().any(|name| column.eq_ignore_ascii_case(name)))
        .ok_or_else(|| format!("{VULNS_FILE} is missing the {} column", names[0]))
}

// sbomnix drops the column for a scanner that failed, so a missing scanner
// column means the report is degraded rather than clean
fn present_scanners(header: &[String]) -> Vec<&'static str> {
    SCANNERS
        .into_iter()
        .filter(|scanner| {
            header
                .iter()
                .any(|column| column.eq_ignore_ascii_case(scanner))
        })
        .collect()
}

struct Columns {
    vuln_id: usize,
    url: usize,
    package: usize,
    version: usize,
    severity: usize,
    sum: usize,
}

impl Columns {
    fn from_header(header: &[String]) -> Result<Self, String> {
        Ok(Self {
            vuln_id: column(header, &["vuln_id"])?,
            url: column(header, &["url"])?,
            package: column(header, &["package"])?,
            version: column(header, &["version_local", "version"])?,
            severity: column(header, &["severity"])?,
            sum: column(header, &["sum"])?,
        })
    }

    fn row(&self, record: &[String]) -> Row {
        Row {
            vuln_id: field(record, self.vuln_id).to_string(),
            url: field(record, self.url).to_string(),
            package: field(record, self.package).to_string(),
            version: field(record, self.version).to_string(),
            severity: number(record, self.severity),
        }
    }
}

fn load_rows(input: &str) -> Result<Vec<Row>, String> {
    let mut records = parse_csv(input)?;
    if records.is_empty() {
        return Err(format!("{VULNS_FILE} is empty"));
    }

    let header = records
        .remove(0)
        .into_iter()
        .map(|column| column.trim_start_matches('\u{feff}').trim().to_string())
        .collect::<Vec<_>>();

    let columns = Columns::from_header(&header)?;

    let scanners = present_scanners(&header);
    let degraded = scanners.len() < SCANNERS.len();
    if degraded {
        let missing = SCANNERS
            .iter()
            .filter(|scanner| !scanners.contains(scanner))
            .copied()
            .collect::<Vec<_>>()
            .join(", ");
        eprintln!(
            "WARNING: degraded scan: only {}/{} scanners reported (missing: {missing}); keeping single-scanner findings",
            scanners.len(),
            SCANNERS.len()
        );
    }

    // require corroboration only when every scanner ran; otherwise a failed
    // scanner would hide all findings instead of just lowering confidence
    let min_sum = if degraded { 1.0 } else { 2.0 };

    Ok(records
        .into_iter()
        .filter(|record| number(record, columns.sum) >= min_sum)
        .map(|record| columns.row(&record))
        .collect())
}

fn format_entry(entry: &str, width: usize) -> String {
    format!("{entry:<width$}")
}

// debug formatting keeps `.0` on whole floats, matching Python's `str(float)`
fn format_score(score: f64) -> String {
    format!("{score:?}")
}

fn push_row(output: &mut String, cells: &[String]) {
    output.push_str("| ");
    output.push_str(&cells.join(" | "));
    output.push_str(" |\n");
}

fn push_separator(output: &mut String, widths: &[usize]) {
    output.push('|');
    widths.iter().for_each(|width| {
        output.push_str(&"-".repeat(width + PADDING));
        output.push('|');
    });
    output.push('\n');
}

fn render(rows: &[Row]) -> String {
    let mut widths = Widths {
        cat: "Category".len(),
        count: "Count".len(),
        pkg: "Package".len(),
        ver: "Version".len(),
        cve: "CVE".len(),
        score: "Score".len(),
        link: "Link".len(),
    };
    let mut categories = [
        ("Total", rows.len()),
        ("Critical", 0),
        ("High", 0),
        ("Medium", 0),
        ("Low", 0),
    ];

    // widths are sized from critical rows only; category counts cover every row
    rows.iter().for_each(|row| {
        let critical = row.severity >= CRITICAL_SCORE;
        let category = if critical {
            1
        } else if row.severity >= HIGH_SCORE {
            2
        } else if row.severity >= MEDIUM_SCORE {
            3
        } else {
            4
        };
        categories[category].1 += 1;

        if critical {
            widths.cve = widths.cve.max(row.vuln_id.chars().count());
            widths.link = widths.link.max(row.url.chars().count());
            widths.pkg = widths.pkg.max(row.package.chars().count());
            widths.ver = widths.ver.max(row.version.chars().count());
        }
    });

    let mut output = String::from("# Vulnxscan Results\n\n## Vulnerability Counts\n\n");

    push_row(
        &mut output,
        &[
            format_entry("Category", widths.cat),
            format_entry("Count", widths.count),
        ],
    );
    push_separator(&mut output, &[widths.cat, widths.count]);
    categories.iter().for_each(|(name, count)| {
        push_row(
            &mut output,
            &[
                format_entry(name, widths.cat),
                format_entry(&count.to_string(), widths.count),
            ],
        );
    });

    output.push_str("\n\n## Critical Vulnerabilities\n\n");
    push_row(
        &mut output,
        &[
            format_entry("Package", widths.pkg),
            format_entry("Version", widths.ver),
            format_entry("CVE", widths.cve),
            format_entry("Score", widths.score),
            format_entry("Link", widths.link),
        ],
    );
    push_separator(
        &mut output,
        &[
            widths.pkg,
            widths.ver,
            widths.cve,
            widths.score,
            widths.link,
        ],
    );
    rows.iter()
        .filter(|row| row.severity >= CRITICAL_SCORE)
        .for_each(|row| {
            push_row(
                &mut output,
                &[
                    format_entry(&row.package, widths.pkg),
                    format_entry(&row.version, widths.ver),
                    format_entry(&row.vuln_id, widths.cve),
                    format_entry(&format_score(row.severity), widths.score),
                    format_entry(&row.url, widths.link),
                ],
            );
        });

    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn uses_sum_column_instead_of_sortcol() {
        let input = "vuln_id,url,package,version_local,severity,grype,osv,vulnix,sum,sortcol\n\
CVE-2026-1,https://example/1,ffmpeg,9.0.2,6.8,1,0,0,1,2026A0000120247\n\
CVE-2026-2,https://example/2,ffmpeg,9.0.2,9.8,1,1,0,2,2026A0000120246\n";
        let rows = load_rows(input).unwrap();
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].vuln_id, "CVE-2026-2");
    }

    #[test]
    fn finds_columns_by_name_and_parses_quoted_fields() {
        let input = "sortcol,sum,url,vuln_id,package,version,severity,grype,osv,vulnix\n\
\"2026A0000120247\",2,\"https://example/3,a\",\"CVE-2026-3\",\"pkg,quoted\",\"1.0\",\"9.0\",1,1,0\n";
        let rows = load_rows(input).unwrap();
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].url, "https://example/3,a");
        assert_eq!(rows[0].package, "pkg,quoted");
        assert_eq!(rows[0].severity, 9.0);
    }

    #[test]
    fn keeps_single_scanner_rows_when_a_scanner_is_missing() {
        let input = "vuln_id,url,package,version_local,severity,grype,osv,sum\n\
CVE-2026-1,https://example/1,ffmpeg,9.0.2,9.8,1,0,1\n";
        let rows = load_rows(input).unwrap();
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].vuln_id, "CVE-2026-1");
    }

    #[test]
    fn formats_scores_like_python() {
        assert_eq!(format_score(9.0), "9.0");
        assert_eq!(format_score(9.8), "9.8");
        assert_eq!(format_score(10.0), "10.0");
    }
}
