* ===========================================================
* WBL Labor Questionnaire Enhancer — GPT-5-mini 
* ===========================================================

clear all
set more off
pause off
mat drop _all

import excel "C:\Users\wb611279\OneDrive - WBG\Desktop\AI Test\Clean_Fin_Extracted_WBL_Questions_Labor_FinalCleaned.xlsx", ///
    sheet("Sheet1") firstrow clear
	
python
import os, ssl, certifi, httpx, json, re, sys
from openai import OpenAI
from sfi import Data

# --- CONFIG ---
MODEL = "gpt-5-mini"
API_KEY = ""   
MAX_TOKENS = 6000
TIMEOUT = 600

if not API_KEY:
    raise RuntimeError("Missing OPENAI_API_KEY – please provide one.")

_ctx = ssl.create_default_context(cafile=certifi.where())
_http = httpx.Client(verify=_ctx, timeout=TIMEOUT, follow_redirects=True)
client = OpenAI(api_key=API_KEY, http_client=_http)

# --- SYSTEM PROMPT ---
SYSTEM_PROMPT = """
You are a World Bank expert specializing in labor market regulations under the Women, Business and the Law (WBL) project.

Task: Review and improve each labor questionnaire question for clarity, policy relevance, and analytical value.

Guidelines:
- Focus on improving the 'Question' field only.
- Keep numbering, variable IDs (e.g., WBL_3_1_1), and options like "01: Yes | 00: No".
- Questions should be concise, objective, and reflect policy or regulatory reality.
- If the question is already clear and sound, confirm no rephrasing is needed.
- Avoid translation or extra commentary beyond the format.

Output Format (STRICT):
Analysis: [short evaluation of clarity, focus, and policy value]
Revised Question: [improved question text or "No rephrasing needed."]
""".strip()

# --- HELPER FUNCTIONS ---
def safe_text(rsp):
    try:
        return rsp.output_text.strip()
    except Exception:
        if hasattr(rsp, "output") and isinstance(rsp.output, list):
            for o in rsp.output:
                if hasattr(o, "content"):
                    for c in o.content:
                        if getattr(c, "type", "") == "output_text":
                            return c.text.strip()
        return str(rsp)[:4000].strip()

def call_openai(prompt):
    try:
        rsp = client.responses.create(
            model=MODEL,
            input=prompt,
            max_output_tokens=MAX_TOKENS,
            store=True
        )
        return safe_text(rsp)
    except Exception as e:
        sys.stderr.write(f"⚠️ API error: {e}\n")
        return ""

def parse_reply(text):
    if not text: return "", ""
    a = re.search(r"(?i)analysis:\s*(.*?)(?=\n\S|$)", text, re.S)
    r = re.search(r"(?i)revised question:\s*(.*)", text, re.S)
    return (a.group(1).strip() if a else "", r.group(1).strip() if r else "")

# --- SETUP STATA VARIABLES ---
N = Data.getObsTotal()
Data.addVarStr("Analysis", 2000)
Data.addVarStr("RevisedQuestion", 1000)

q_idx = Data.getVarIndex("Question")
a_idx = Data.getVarIndex("Analysis")
r_idx = Data.getVarIndex("RevisedQuestion")

# --- MAIN LOOP ---
for i in range(N):
    q = Data.getAt(q_idx, i)
    if not q or str(q).strip() == "":
        continue

    sys.stderr.write(f"[{i+1}] Enhancing question...\n")
    user_prompt = f"Question:\n{q.strip()}"
    raw = call_openai(f"{SYSTEM_PROMPT}\n\n{user_prompt}")
    analysis, revised = parse_reply(raw)

    Data.storeAt(a_idx, i, analysis)
    Data.storeAt(r_idx, i, revised)

    sys.stderr.write(f"[{i+1}] ✅ Done.\n")

end

export excel using "C:\Users\wb611279\OneDrive - WBG\Desktop\AI Test\EnhancedQuestionnaireWBL.xlsx", ///
    firstrow(variables) replace

