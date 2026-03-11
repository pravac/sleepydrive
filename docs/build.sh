#!/bin/bash

# Combine all the markdown files into a single full_design_document.md
# They are distributed across userdocs, designdocs, and frontenddocs.

cat \
    userdocs/Need_and_Goal_Statement.md \
    designdocs/Design_Objective.md \
    userdocs/Personas.md \
    designdocs/Design.md \
    frontenddocs/Testing_Plan.md \
    > full_design_document.md

echo "Combined distributed markdown files into full_design_document.md"
echo "You can convert this to a PDF using a VS Code extension like 'Markdown PDF' by right clicking full_design_document.md, or using Pandoc if installed."
