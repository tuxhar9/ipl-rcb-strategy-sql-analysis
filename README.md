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

## 🗄️ Database Structure — 20 Tables

`Ball_by_Ball` · `Matches` · `Player` · `Team` · `Season` · `Venue` · `Wicket_Taken`  
`Extra_Runs` · `Player_Match` · `Batting_Style` · `Bowling_Style` · `City` · `Country`  
`Out_Type` · `Outcome` · `Rolee` · `Toss_Decision` · `Umpire` · `Win_By` · `Extra_Type`

---

## 📊 Key Queries Covered

### Objective (Q1–Q15)
- Data type inspection using `information_schema`
- RCB season-wise run totals including extras
- Player age analysis using `TIMESTAMPDIFF`
- Top 10 batsmen by strike rate (min. 200 balls)
- Average runs & wickets per player across all seasons
- All-rounder identification using CTEs
- Venue win/loss record stored in a created table (`rcb_record`)
- Bowling style impact on wickets
- Year-on-year team performance using `LAG()` window function
- 5 Advanced KPIs: Powerplay RR, Death RR, Economy, Dot Ball %, Boundary %
- Bowler ranking by venue using `DENSE_RANK()`
- Consistent performers across all 4 seasons

### Subjective (Q1–Q10)
- Toss decision impact on match results (overall + venue-wise)
- Best player recommendations with a composite score formula
- Versatile all-rounders (bat + ball) identified via CTEs
- Man of the Match influence on team morale
- RCB season performance breakdown with reasons for not winning
- High-scoring match factors and viewership impact
- Home ground advantage analysis (Chinnaswamy vs Away)
- Mega auction strategy — 6 data-backed recommendations

---

## 💡 Key Findings

- **AB de Villiers** leads strike rate at **164.27** — most destructive batsman across 4 seasons
- **Virat Kohli** averages **39.87 runs/match** across 62 matches — most consistent RCB batsman
- **Teams choosing to field after winning the toss** have a higher win percentage
- **RCB's home win rate at Chinnaswamy** is significantly higher than their away record
- **Fast Medium bowlers** dominate wicket counts across all seasons

---

## 🏆 Auction Recommendations for RCB

1. Prioritize a reliable **opening partner** for Kohli
2. Invest in a **death-over specialist bowler** (Economy < 8 in overs 16–20)
3. Sign **1–2 genuine all-rounders** who bat at SR > 140 and bowl at Economy < 7.5
4. Target players with **strong Chinnaswamy records** for home advantage
5. Avoid over-spending on bowlers with **high economy rates in powerplay**
6. Build a **spin-heavy bowling lineup** based on economy and dot ball data

---

## 📁 Project Files

| File | Description |
|---|---|
| `ipl_analysis.sql` | All 25 SQL queries — objective + subjective |
| `IPL_Analysis_Presentation.pptx` | Slide deck with visualizations and findings |
| `IPL_Analysis_Report.docx` | Detailed written answers with insights |

---

## 👨‍💻 Author

**Tushar Naha** 

Data Analytics Enthusiast  

