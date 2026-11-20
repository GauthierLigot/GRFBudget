# GRFBudget

R Shiny app for planning staff budgets across research projects: salaries per employee/year,
projects with budgets, and allocations (employee × project × period × FTE). It computes monthly
expenses and the remaining budget per project. Deployed on shinyapps.io.

## Running the app

R is installed at `C:\Program Files\R\R-4.6.0` but is **not on PATH**. Use the full path:

```powershell
& "C:\Program Files\R\R-4.6.0\bin\Rscript.exe" -e "shiny::runApp('.', port = 8080, launch.browser = FALSE)"
```

Then open http://127.0.0.1:8080. Run it from the repo root, because paths like `data/current_data.xlsx` are relative.

Packages: shiny, bslib, ggplot2, openxlsx2, dplyr, lubridate, DT, jsonlite, Hmisc (for `Hmisc::monthDays`).
There is no renv lockfile. If a package is missing, ask before installing it.

There are no automated tests. To check a change, run the app and use it: edit tables, then
click Compute on the Results tab.

## Structure

- `app.R`: loads libraries, `source()`s every file in `R/`, and defines a `page_navbar` UI with one tab per module.
  **A new file in `R/` must be added to the `source()` list in `app.R`.**
- `R/app_data.R`: `create_app_data()`, the shared `reactiveValues` holding the three input tables
  (`salary`, `project`, `allocation`) and `current_file`.
- `R/output_data.R`: `create_output_data()`, a `reactiveValues` holding the computed result tables.
- `R/io.R`: reads and writes Excel files with openxlsx2. The input workbook has the sheets `salary`, `project` and `allocation`.
- `R/compute.R`: `compute(app_data)` expands each allocation into monthly rows (prorating partial
  months) and joins them with salary and project data to produce the summaries. Years are grouped as
  academic years from July to June (`year_july`, e.g. `"2025-2026"`).
- `R/validation_warnings.R`: consistency checks that return a ✓/⚠ text message.
- `R/mod_*.R`: Shiny modules (`xxx_ui(id)` / `xxx_server(id, app_data, ...)`), one per tab:
  file, salary, project, allocation, results.
- `dev/`: scratch and exploration scripts. They are not part of the app.
- `rsconnect/`: shinyapps.io deployment metadata. Don't edit it by hand.

## Data model

| table | key columns | notes |
|---|---|---|
| salary | employee, year | fte, salary (gross €/month), comment |
| project | project_code | otp, project_name, budget, start_date, end_date, comment |
| allocation | project_code + employee | start_date, end_date, fte, comment |

`expense = salary * fte_project / fte * work_days_prop` (computed per month).

## Conventions and patterns

- The editable tables (salary, project, allocation) use the same DT pattern:
  - `renderDT` uses `isolate()` on the data, so cell edits never re-render the widget;
  - cell edits write straight into `app_data$<table>`, with type coercion;
  - `refresh_table()` pushes changes through `DT::dataTableProxy` + `replaceData(resetPaging = FALSE)`,
    which keeps the current page and search.
  Keep this pattern. A full re-render loses the user's page position and is slow.
- In the allocation table, `project_code` and `employee` are edited through a custom JS dropdown
  (capture-phase dblclick handler in `mod_allocation.R`) that sends `input$select_edit`.
- Code style: tidyverse pipes (`%>%` and `|>` are both used), snake_case, and `dplyr::` prefixes in some places.
- The UI language is English.

## Things to be careful with

- `data/current_data.xlsx` is the real working data, loaded at startup and overwritten by "Save".
  Don't modify it, overwrite it or commit changes to it. For testing, use a copy, or load a
  file through the File tab.
- Never put credentials (shinyapps.io token/secret) in tracked files. Use
  `rsconnect::setAccountInfo()` interactively, or environment variables.
- Work on a branch, never commit directly to `main`, and only commit or push when asked.
