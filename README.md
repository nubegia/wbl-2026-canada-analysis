# wbl-2026-canada-analysis

## Overview

This project implements an AI-assisted legal research and evaluation pipeline for the **World Bank’s Women, Business and the Law (WBL) 2026** dataset.  
It fulfills **Tasks B1 – B5** of the technical assessment by automating authoritative retrieval, structured answer generation, adjudicator review, and confidence calibration.  
The pipeline uses the **OpenAI GPT-5-mini model** through the Responses API with persistent logging (`store=True`), exponential-backoff retry logic, and cached requests.  
Each question from the input spreadsheet is processed to produce:
- A legally grounded structured answer (A0)
- Citations and links to primary sources
- Confidence and latency metrics
- An independent evaluator verdict including justification, corrected answer, and confidence

Outputs are exported to both **CSV** and **Excel**.
