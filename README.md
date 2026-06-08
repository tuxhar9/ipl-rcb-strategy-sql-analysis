# 🏏 IPL RCB Strategy Analysis — SQL

> SQL-powered performance analysis across 4 IPL seasons (2013–2016)  
> to build a data-driven auction strategy for Royal Challengers Bangalore.

---

## 📌 Project Overview

Royal Challengers Bangalore — the most passionate yet trophy-less franchise in IPL history.  
This project uses SQL to analyze player performance, team patterns, venue trends, and toss decisions  
across 4 seasons to answer one question: **What does RCB need to finally win?**

---

## 🛠️ Tools & Concepts Used

| Category | Details |
|---|---|
| **Database** | MySQL |
| **Concepts** | Joins, Subqueries, CTEs, Window Functions, Aggregations |
| **KPIs Built** | Powerplay Run Rate, Death Over Rate, Economy Rate, Dot Ball %, Boundary % |
| **Analysis Type** | Objective Queries + Subjective Business Questions |

---

---

## 🗄️ Database Structure — 20 Tables

| Core Tables | Reference Tables |
|---|---|
| `Ball_by_Ball` — every delivery bowled | `Batting_Style`, `Bowling_Style` |
| `Matches` — match results & details | `City`, `Country`, `Venue` |
| `Player` — profiles & DOB | `Out_Type`, `Outcome`, `Rolee` |
| `Wicket_Taken` — every dismissal | `Toss_Decision`, `Win_By` |
| `Extra_Runs` — wides, no-balls | `Extra_Type`, `Umpire` |
| `Player_Match`, `Team`, `Season` | |

---

## 📊 Queries Covered

### ✅ Objective Queries (Q1–Q15)

| # | Query | Key Result |
|---|---|---|
| Q1 | Column data types via `information_schema` | All 11 cols = INT |
| Q2 | RCB total runs in Season 1 (incl. extras) | **2,601 runs** |
| Q3 | Players aged >25 in 2014 | **92 players** |
| Q4 | RCB wins in 2013 | **9 wins — 56.25%** |
| Q5 | Top 10 batsmen by strike rate | **ABD leads: 164.27** |
| Q6 | Average runs per batsman | **Simmons: 42.82/match** |
| Q7 | Average wickets per bowler | **Bravo: 1.65/match** |
| Q8 | All-rounders above average (bat + bowl) | CTE-based filter |
| Q9 | RCB venue win/loss table (created table) | `rcb_record` table |
| Q10 | Bowling style impact on wickets | Fast Medium dominates |
| Q11 | YoY team performance using `LAG()` | Better / Worse / Same |
| Q12 | 5 Advanced KPIs | Powerplay RR, Death RR, Economy, Dot Ball %, Boundary % |
| Q13 | Bowler ranking by venue using `DENSE_RANK()` | Top performers per ground |
| Q14 | Consistent performers across 4 seasons | Kohli, Warner, ABD |
| Q15 | Venue-specific player performance | Player-ground fit analysis |

### 💬 Subjective Queries (Q1–Q10)

- Toss decision impact (overall + venue-specific)
- Best fit players using a composite score formula
- All-rounder identification via dual CTEs
- Man of the Match influence on team morale
- RCB season-by-season breakdown with trophy failure analysis
- High-scoring match factors and viewership impact
- Home ground advantage at Chinnaswamy
- Mega auction strategy — **6 data-backed recommendations**

---

## 💡 Key Findings

| Insight | Finding |
|---|---|
| 🏏 Best Batsman (SR) | AB de Villiers — **164.27** |
| 📊 Most Consistent | Virat Kohli — **39.87 avg over 62 matches** |
| 🎯 Best Economy | Top bowlers under **6.5 runs/over** |
| 🏟️ Home Advantage | RCB wins significantly more at Chinnaswamy |
| 🪙 Toss Impact | **Fielding first = higher win %** across most venues |
| 🎳 Best Bowling Style | Fast Medium bowlers lead in total wickets |

---

## 🏆 Auction Recommendations for RCB

1. **Retain Kohli + ABD** — the core batting spine is non-negotiable
2. Sign a **reliable opening partner** for Kohli (avg > 35, SR > 130)
3. Invest in a **death-over specialist** — economy < 8 in overs 16–20
4. Add **1–2 genuine all-rounders** — SR > 140 batting, economy < 7.5 bowling
5. Target players with **proven Chinnaswamy performance** for home edge
6. Build a **spin-heavy attack** based on dot ball % and economy data

---

## 📂 Project Files

| File | Description |
|---|---|
| `ipl_analysis.sql` | All 25 SQL queries — objective + subjective with comments |
| `IPL_Analysis_Presentation.pptx` | Slide deck with charts and insights |
| `IPL_Analysis_Report.docx` | Detailed written answers with analysis |

---

## 👨‍💻 Author

**Tushar Naha** 

Data Analytics Enthusiast

