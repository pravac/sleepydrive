#!/bin/bash

# Build script for the SleepyDrive Design Document
# Combines all distributed markdown files into a single full_design_document.md
# following the document structure from Drawing Board:
#
#  1.  Title Page (in Design Alejandro and Prana.md header)
#  2.  Table of Contents (in Design Alejandro and Prana.md)
#  3.  Introduction + Need & Goal Statements (in Design Alejandro and Prana.md)
#  4.  Personas (userdocs/Personas.md)
#  5.  Existing Designs & Products Research (designdocs/Design_Objective.md)
#  6.  Sustainability Statement (placeholder)
#  7.  Design Features 7.1–7.5 (PRAVIN DESIGN DOC.md)
#  8.  Block Diagrams (in Design Alejandro and Prana.md — Technology section)
#  9.  State Transition Diagrams (in Design Alejandro and Prana.md — State Machine)
# 10.  Technology (in Design Alejandro and Prana.md)
# 11.  Design — Aesthetic Prototype / DFM (designdocs/Design.md)
# 12.  Functional Prototype & Testing (frontenddocs/Testing_Plan.md, backenddocs/Testing_Plan.md)
# 13.  Frontend Documentation (frontenddocs/FRONTEND.md)
#
# Plus appendix sections carried over from the other project structure.

set -e

DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$DOCS_DIR/full_design_document.md"

# --- Helper: include a file if it exists, otherwise print a placeholder ---
include() {
    local file="$1"
    local label="$2"
    if [ -f "$DOCS_DIR/$file" ]; then
        cat "$DOCS_DIR/$file"
        printf '\n\n'
    else
        printf '<!-- TODO: %s — file not found: %s -->\n\n' "$label" "$file"
    fi
}

# ============================================================
#  Build the document
# ============================================================
{
    # --- 1–3. Title Page, Table of Contents, Introduction, Need & Goal ---
    include "designdocs/Design Alejandro and Prana.md"   "Title Page / TOC / Introduction / Need & Goal / Technology / Diagrams"

    # --- 4. Personas ---
    include "userdocs/Personas.md"                       "Personas"

    # --- 5. Existing Designs & Products Research ---
    include "designdocs/Design_Objective.md"             "Existing Designs & Products Research"

    # --- 6. Sustainability Statement ---
    include "userdocs/Sustainability_Statement.md"       "Sustainability Statement"

    # --- 7. Design Features (7.1–7.5) ---
    include "designdocs/PRAVIN DESIGN DOC.md"            "Design Features (Driver Monitoring, Alerts, App, Fleet, Architecture)"

    # --- 8–9. Block Diagrams & State Transition Diagrams ---
    #     (already embedded via images in "Design Alejandro and Prana.md")

    # --- 10–11. Design — Aesthetic Prototype, DFM/A/M ---
    include "designdocs/Design.md"                       "Design (Aesthetic Prototype, DFM/A/M)"

    # --- 12. Functional Prototype & Testing ---
    include "userdocs/Testing_Plan.md"               "Frontend Testing Plan / Functional Prototype"

    # --- 13. Frontend Documentation ---
    include "frontenddocs/FRONTEND.md"                   "Frontend Documentation"

    # --- Need & Goal (standalone, if different from the one above) ---
    include "userdocs/Need_and_Goal_Statement.md"        "Need & Goal Statement (standalone)"

    # ============================================================
    #  APPENDICES (placeholders for sections from academic template)
    # ============================================================
    include "designdocs/appendix-1-problem-formulation.md"  "Appendix 1 — Problem Formulation"
    include "designdocs/appendix-2.md"             "Appendix 2 — Planning"
    include "appendices/Appendix_3_Test_Plan_Results.md"    "Appendix 3 — Test Plan & Results"
    include "appendices/Appendix_4_Review.md"               "Appendix 4 — Review"

} > "$OUTPUT"

echo "✅  Built $OUTPUT"
echo ""
echo "Missing sections (if any) are marked with <!-- TODO --> comments in the output."
echo "Convert to PDF with:  pandoc full_design_document.md -o design_document.pdf --toc --pdf-engine=xelatex -V geometry:margin=1in"
