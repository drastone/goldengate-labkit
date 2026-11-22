#!/bin/bash
set -euo pipefail

LAB_DIR=/home/oracle/labs/lab19
OUT_FILE="${LAB_DIR}/gold_channel_action_dashboard.html"

echo "Build Gold channel action dashboard"
printf "Host: "; uname -n
printf "Gold table: insurance.gold_channel_action_candidate\n"
printf "Output    : %s\n\n" "${OUT_FILE}"

docker run --rm -i --network host \
  -v "${LAB_DIR}:/out" \
  oracle-demo_pyiceberg_writer python - <<'PY'
from collections import defaultdict
from datetime import datetime
from html import escape
from pathlib import Path

from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchTableError

OUT = Path("/out/gold_channel_action_dashboard.html")

catalog = load_catalog(
    "insurance",
    type="rest",
    uri="http://127.0.0.1:38181",
    **{
        "s3.endpoint": "http://127.0.0.1:38900",
        "s3.access-key-id": "admin",
        "s3.secret-access-key": "WElcome1234##",
        "s3.path-style-access": "true",
    },
)

try:
    table = catalog.load_table("insurance.gold_channel_action_candidate")
except NoSuchTableError:
    raise SystemExit("Gold table does not exist. Run build_gold_channel_action.sh first.")

rows = table.scan().to_arrow().to_pylist()
priority_rank = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
channel_summary = defaultdict(int)
action_groups = defaultdict(list)

for row in rows:
    channel_summary[(row.get("priority"), row.get("channel"))] += 1
    action_groups[row.get("action_type")].append(row)

total = len(rows)
high = sum(1 for row in rows if row.get("priority") == "HIGH")
call = sum(1 for row in rows if row.get("channel") == "CALL")
auto = sum(1 for row in rows if row.get("channel") in ("SMS", "EMAIL"))

def fmt(n):
    return f"{n:,}"

def esc(value):
    return escape("" if value is None else str(value))

summary_rows = []
for (priority, channel), count in sorted(
    channel_summary.items(),
    key=lambda kv: (priority_rank.get(kv[0][0], 9), kv[0][1] or ""),
):
    summary_rows.append(
        f"<tr><td>{esc(priority)}</td><td>{esc(channel)}</td><td>{fmt(count)}</td></tr>"
    )

action_rows = []
for action_type, items in sorted(
    action_groups.items(),
    key=lambda kv: (priority_rank.get(kv[1][0].get("priority"), 9), kv[0] or ""),
):
    items = sorted(items, key=lambda r: (-int(r.get("event_count") or 0), r.get("cust_id") or 0))
    example = items[0]
    reason = example.get("reason") or ""
    action_rows.append(
        "<tr>"
        f"<td>{esc(action_type)}</td>"
        f"<td><span class='badge {esc(example.get('priority', '').lower())}'>{esc(example.get('priority'))}</span></td>"
        f"<td>{esc(example.get('channel'))}</td>"
        f"<td>{fmt(len(items))}</td>"
        f"<td>{esc(example.get('cust_id'))}</td>"
        f"<td>{esc(reason)}</td>"
        "</tr>"
    )

top_rows = sorted(
    rows,
    key=lambda r: (
        priority_rank.get(r.get("priority"), 9),
        -int(r.get("event_count") or 0),
        r.get("cust_id") or 0,
    ),
)[:12]

cards = []
for row in top_rows:
    cards.append(
        "<article class='candidate'>"
        f"<div class='candidate-head'><strong>고객 {esc(row.get('cust_id'))}</strong>"
        f"<span class='badge {esc(row.get('priority', '').lower())}'>{esc(row.get('priority'))}</span></div>"
        f"<div class='meta'>{esc(row.get('action_type'))} · {esc(row.get('channel'))} · 이벤트 {esc(row.get('event_count'))}건</div>"
        f"<p>{esc(row.get('reason'))}</p>"
        "</article>"
    )

generated_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
html = f"""<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gold Channel Action Dashboard</title>
  <style>
    :root {{
      --ink: #111827;
      --muted: #64748b;
      --line: #d7dee8;
      --bg: #f6f8fb;
      --panel: #ffffff;
      --blue: #2563eb;
      --green: #059669;
      --amber: #b45309;
      --red: #dc2626;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      font-family: Arial, "Malgun Gothic", sans-serif;
      color: var(--ink);
      background: var(--bg);
    }}
    header {{
      padding: 18px 28px;
      background: #172033;
      color: #fff;
      border-bottom: 4px solid #38bdf8;
    }}
    header h1 {{ margin: 0 0 6px; font-size: 24px; }}
    header p {{ margin: 0; color: #cbd5e1; }}
    main {{ max-width: 1440px; margin: 0 auto; padding: 20px 28px 32px; }}
    .metrics {{
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 12px;
      margin-bottom: 16px;
    }}
    .metric {{
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 14px 16px;
      box-shadow: 0 1px 3px rgba(15, 23, 42, 0.08);
    }}
    .metric span {{ display: block; color: var(--muted); font-size: 13px; margin-bottom: 6px; }}
    .metric strong {{ font-size: 28px; }}
    .grid {{
      display: grid;
      grid-template-columns: 0.9fr 1.4fr;
      gap: 16px;
      align-items: start;
    }}
    section {{
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 16px;
      box-shadow: 0 1px 3px rgba(15, 23, 42, 0.08);
    }}
    h2 {{ margin: 0 0 12px; font-size: 18px; }}
    table {{ width: 100%; border-collapse: collapse; font-size: 14px; }}
    th, td {{ padding: 9px 8px; border-bottom: 1px solid #e5eaf1; text-align: left; vertical-align: top; }}
    th {{ color: #334155; background: #f8fafc; }}
    td:nth-child(4), td:nth-child(5) {{ text-align: right; }}
    .badge {{
      display: inline-block;
      min-width: 54px;
      text-align: center;
      border-radius: 999px;
      padding: 3px 8px;
      font-size: 12px;
      font-weight: 700;
      color: #fff;
    }}
    .high {{ background: var(--red); }}
    .medium {{ background: var(--amber); }}
    .low {{ background: var(--green); }}
    .candidates {{
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 12px;
    }}
    .candidate {{
      border: 1px solid #dbe3ef;
      border-radius: 8px;
      padding: 12px;
      background: #fbfdff;
      min-height: 132px;
    }}
    .candidate-head {{ display: flex; justify-content: space-between; gap: 8px; align-items: center; }}
    .meta {{ margin-top: 6px; color: var(--muted); font-size: 13px; }}
    .candidate p {{ margin: 10px 0 0; line-height: 1.55; font-size: 14px; }}
    footer {{ margin-top: 14px; color: var(--muted); font-size: 12px; }}
    @media (max-width: 980px) {{
      .metrics, .grid, .candidates {{ grid-template-columns: 1fr; }}
    }}
  </style>
</head>
<body>
  <header>
    <h1>Gold Channel Action Dashboard</h1>
    <p>GoldenGate Data Streams로 공급된 CDC event를 Iceberg Bronze/Silver/Gold로 정제한 고객 채널 실행 후보입니다.</p>
  </header>
  <main>
    <div class="metrics">
      <div class="metric"><span>전체 후보</span><strong>{fmt(total)}</strong></div>
      <div class="metric"><span>즉시 연락</span><strong>{fmt(high)}</strong></div>
      <div class="metric"><span>상담/전화</span><strong>{fmt(call)}</strong></div>
      <div class="metric"><span>자동 안내</span><strong>{fmt(auto)}</strong></div>
    </div>
    <div class="grid">
      <section>
        <h2>Channel Workload</h2>
        <table>
          <thead><tr><th>Priority</th><th>Channel</th><th>Candidates</th></tr></thead>
          <tbody>{''.join(summary_rows)}</tbody>
        </table>
      </section>
      <section>
        <h2>Gold Data Product</h2>
        <table>
          <thead><tr><th>Action Type</th><th>Priority</th><th>Channel</th><th>Candidates</th><th>Example</th><th>Reason</th></tr></thead>
          <tbody>{''.join(action_rows)}</tbody>
        </table>
      </section>
    </div>
    <section style="margin-top:16px">
      <h2>Priority Action Candidates</h2>
      <div class="candidates">{''.join(cards)}</div>
    </section>
    <footer>Generated at {esc(generated_at)} from insurance.gold_channel_action_candidate.</footer>
  </main>
</body>
</html>
"""

OUT.write_text(html, encoding="utf-8")
print(f"Dashboard written: {OUT}")
print(f"Rows: {total}")
print(f"High priority: {high}")
PY

echo
echo "Dashboard file ready:"
ls -l "${OUT_FILE}"
