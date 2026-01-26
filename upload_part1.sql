-- =====================================================
-- COMPLETE NCLEX QUESTIONS DATABASE
-- Run this in Supabase SQL Editor
-- =====================================================

-- Create tables
CREATE TABLE IF NOT EXISTS content_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version TEXT NOT NULL UNIQUE,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    is_current BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS nclex_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    wrong_answers JSONB NOT NULL DEFAULT '[]',
    rationale TEXT,
    content_category TEXT NOT NULL,
    nclex_category TEXT NOT NULL,
    difficulty TEXT NOT NULL DEFAULT 'medium',
    question_type TEXT NOT NULL DEFAULT 'standard',
    is_premium BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    version TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PART 1: ORIGINAL 525 QUESTIONS (v1.0.0)
-- =====================================================
INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B3D86199-3A11-42BD-B6D5-AA956B4DED10',
    'What is the FIRST action a nurse should take when a patient falls?',
    'Assess the patient for injuries',
    '["Call the physician", "Complete an incident report", "Help the patient back to bed"]',
    'Patient safety is the priority. Before any other action, the nurse must assess for injuries to determine the severity and appropriate interventions. Documentation and notification come after ensuring patient safety.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '526504D1-C6F4-49E1-9354-26F85E7558CC',
    'Which vital sign change indicates a patient may be developing shock?',
    'Decreased blood pressure with increased heart rate',
    '["Increased blood pressure with decreased heart rate", "Normal blood pressure with normal heart rate", "Decreased blood pressure with decreased heart rate"]',
    'In early compensatory shock, the body attempts to maintain perfusion by increasing heart rate (tachycardia) as blood pressure drops. This compensatory mechanism is a key early warning sign.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '52859F98-EC90-4309-B7E2-71B7E8805B26',
    'A nurse is preparing to administer medications. Which action demonstrates proper patient identification?',
    'Check two patient identifiers and compare with the MAR',
    '["Ask the patient their name only", "Check the room number", "Verify with the patient''s family member"]',
    'The Joint Commission requires two patient identifiers (name and DOB, or name and medical record number) before medication administration. Room numbers should never be used as identifiers.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DB01C3C2-BDEA-4823-A7C3-7DB6157B4E17',
    'What is the correct order for performing a physical assessment?',
    'Inspection, palpation, percussion, auscultation',
    '["Palpation, inspection, percussion, auscultation", "Auscultation, inspection, palpation, percussion", "Percussion, palpation, auscultation, inspection"]',
    'The correct sequence is Inspection (visual), Palpation (touch), Percussion (tapping), Auscultation (listening). Exception: For abdominal assessment, auscultate before palpation to avoid altering bowel sounds.',
    'Fundamentals',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CDF0ABB8-2983-460D-B8DB-24A7E8FBCD55',
    'A patient has a blood pressure of 88/56 mmHg. Which position should the nurse place the patient in?',
    'Supine with legs elevated (modified Trendelenburg)',
    '["High Fowler''s position", "Prone position", "Left lateral position"]',
    'For hypotensive patients, elevating the legs helps return blood to the central circulation, improving cardiac output and blood pressure. High Fowler''s would worsen hypotension by pooling blood in the lower extremities.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A7983D7D-4CBF-4DB4-8DD4-9C9B2893DE2E',
    'Which nursing intervention is MOST important for preventing hospital-acquired infections?',
    'Performing hand hygiene before and after patient contact',
    '["Wearing gloves for all patient interactions", "Isolating all patients with infections", "Administering prophylactic antibiotics"]',
    'Hand hygiene is the single most effective way to prevent the spread of infections in healthcare settings. The CDC and WHO emphasize hand hygiene as the cornerstone of infection prevention.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '564234E3-9B0F-4299-B5FD-F039257BE953',
    'A patient is NPO for surgery. Which action by the nurse is appropriate?',
    'Remove the water pitcher and post NPO sign',
    '["Allow ice chips only", "Give medications with a full glass of water", "Permit clear liquids until 2 hours before surgery"]',
    'NPO means nothing by mouth. Removing access to fluids and posting clear signage prevents accidental intake. Specific pre-operative guidelines should be followed per facility protocol and surgeon orders.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '436F52F4-2101-4D03-8006-896EA154C7D6',
    'Select ALL interventions that are appropriate for fall prevention:',
    'Keep bed in lowest position, Ensure call light is within reach, Use non-slip footwear, Keep environment well-lit',
    '["Restrain all high-risk patients"]',
    'Fall prevention is multifaceted: low bed position reduces injury from falls, accessible call light allows patients to ask for help, non-slip footwear prevents slipping, and good lighting helps patients see obstacles. Restraints are a last resort and can increase fall risk.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '632C8584-EB00-4A44-AC8D-DE4C107C40E3',
    'What does the acronym RACE stand for in fire safety?',
    'Rescue, Alarm, Contain, Extinguish',
    '["Run, Alert, Call, Evacuate", "Rescue, Alert, Cover, Exit", "Remove, Alarm, Close, Escape"]',
    'RACE is the fire response protocol: Rescue patients in immediate danger, Activate the Alarm, Contain the fire by closing doors, Extinguish if small and safe to do so. This sequence prioritizes patient safety.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'ED2A140F-8B85-455F-B88B-AE7B409EFE54',
    'A nurse is documenting in the medical record. Which entry is MOST appropriate?',
    'Patient states ''I feel dizzy when I stand up.'' VS: BP 100/60 sitting, 82/50 standing.',
    '["Patient is dizzy, probably dehydrated", "Patient seems to have orthostatic hypotension", "Patient is a poor historian and is confused about symptoms"]',
    'Documentation should be objective, factual, and include direct patient quotes when relevant. Avoid assumptions, diagnoses (unless within scope), and judgmental language. Include measurable data.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '51C3A340-82F6-4516-8FF4-01820022A1B8',
    'A patient with heart failure has gained 3 pounds overnight. What is the nurse''s PRIORITY action?',
    'Assess for edema and lung sounds, then notify the provider',
    '["Restrict fluids immediately", "Administer an extra dose of diuretic", "Encourage increased activity"]',
    'Rapid weight gain (>2-3 lbs in 24 hours) indicates fluid retention, a sign of worsening heart failure. Assessment confirms the finding, and the provider needs notification for medication adjustments. Nurses cannot independently change medication doses.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CC538E44-AED4-4C51-B73B-E2F6034A76C3',
    'Which finding in a patient with diabetes requires IMMEDIATE intervention?',
    'Blood glucose of 45 mg/dL with diaphoresis',
    '["Blood glucose of 180 mg/dL before lunch", "Blood glucose of 95 mg/dL fasting", "HbA1c of 7.2%"]',
    'Hypoglycemia (<70 mg/dL) with symptoms (diaphoresis, confusion, tremors) is a medical emergency requiring immediate treatment with fast-acting glucose. Untreated severe hypoglycemia can lead to seizures, coma, and death.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3CFAE8AF-1DC2-4C6B-8207-4067EEEBE861',
    'A patient post-thyroidectomy reports tingling around the mouth. What should the nurse assess for?',
    'Hypocalcemia (check Chvostek''s and Trousseau''s signs)',
    '["Hyperkalemia", "Thyroid storm", "Allergic reaction to anesthesia"]',
    'Parathyroid glands may be damaged during thyroidectomy, causing hypocalcemia. Perioral tingling is an early sign. Chvostek''s sign (facial twitch when tapping cheek) and Trousseau''s sign (carpopedal spasm with BP cuff) confirm hypocalcemia.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A146BA35-987C-43E3-84DD-207F0BFFFE48',
    'What is the PRIORITY nursing diagnosis for a patient experiencing an acute asthma attack?',
    'Impaired gas exchange',
    '["Anxiety", "Activity intolerance", "Deficient knowledge"]',
    'During an acute asthma attack, bronchospasm and inflammation severely impair oxygen and carbon dioxide exchange. This life-threatening physiological problem takes priority over psychological or educational needs using Maslow''s hierarchy.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C85C0131-E59E-4110-9A39-A84999B7F01B',
    'A patient with COPD has an oxygen saturation of 88%. What is the appropriate oxygen flow rate?',
    '1-2 L/min via nasal cannula, titrate to SpO2 88-92%',
    '["High-flow oxygen at 15 L/min", "100% oxygen via non-rebreather mask", "No oxygen needed, 88% is acceptable for COPD"]',
    'COPD patients have chronic CO2 retention and rely on hypoxic drive for breathing. High-flow oxygen can suppress this drive and cause respiratory failure. Target SpO2 of 88-92% balances oxygenation with maintaining respiratory drive.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '23E55F3E-C4F5-45EE-92BF-0F61B3670EFD',
    'Which assessment finding indicates a patient may be experiencing a stroke?',
    'Sudden onset of facial drooping, arm weakness, and slurred speech',
    '["Gradual onset of bilateral leg weakness over 2 weeks", "Chronic headaches with normal neurological exam", "Intermittent dizziness when changing positions"]',
    'FAST (Face drooping, Arm weakness, Speech difficulty, Time to call 911) identifies stroke symptoms. Sudden onset of unilateral neurological deficits is characteristic. Stroke is time-sensitive - ''time is brain.''',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B254F103-FA4E-4D98-8161-5E962451496A',
    'A patient with cirrhosis has a distended abdomen. Which position is BEST for comfort and breathing?',
    'Semi-Fowler''s or high Fowler''s position',
    '["Supine flat position", "Trendelenburg position", "Prone position"]',
    'Ascites (fluid accumulation) in cirrhosis causes abdominal distension that pushes on the diaphragm, making breathing difficult. Elevating the head of bed allows gravity to pull fluid down and gives the diaphragm more room to expand.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B823A13B-7E3D-4C72-9EA7-16BAE07F4CAC',
    'After a cardiac catheterization via femoral artery, which assessment is PRIORITY?',
    'Check the puncture site for bleeding and assess distal pulses',
    '["Encourage the patient to ambulate immediately", "Assess for pain at the catheter insertion site", "Check blood glucose levels"]',
    'Femoral artery access creates bleeding risk and potential for hematoma or arterial occlusion. Checking the site for bleeding/hematoma and assessing pedal pulses ensures adequate circulation. The patient must remain on bedrest with the leg straight.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '00A00655-9390-428A-8221-5B7706ED3386',
    'A patient with renal failure has a potassium level of 6.8 mEq/L. Which ECG change should the nurse expect?',
    'Tall, peaked T waves',
    '["Flat T waves", "Prolonged QT interval", "ST segment elevation"]',
    'Hyperkalemia causes characteristic ECG changes: tall peaked T waves (early), widened QRS, and eventually sine wave pattern and cardiac arrest. K+ >6.0 mEq/L is dangerous and requires immediate treatment.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3D5FF7EB-F376-4975-9234-F96431771E03',
    'Select ALL signs and symptoms of left-sided heart failure:',
    'Dyspnea, Orthopnea, Crackles in lungs, Pink frothy sputum',
    '["Jugular vein distension"]',
    'Left-sided heart failure causes pulmonary congestion because the left ventricle cannot effectively pump blood forward. Fluid backs up into the lungs causing dyspnea, orthopnea, crackles, and in severe cases, pink frothy sputum (pulmonary edema). JVD is a sign of right-sided failure.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0DB0A35C-E876-4600-804E-D42C870B65EC',
    'A patient is prescribed warfarin. Which lab value should the nurse monitor?',
    'INR (International Normalized Ratio)',
    '["aPTT (activated Partial Thromboplastin Time)", "Platelet count only", "Hemoglobin and hematocrit only"]',
    'Warfarin affects vitamin K-dependent clotting factors (II, VII, IX, X). INR monitors warfarin effectiveness. Therapeutic range is usually 2-3 (2.5-3.5 for mechanical heart valves). aPTT monitors heparin, not warfarin.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '71965DD6-DD52-47B6-B1BB-77FBD3A827F8',
    'What is the antidote for heparin overdose?',
    'Protamine sulfate',
    '["Vitamin K", "Naloxone", "Flumazenil"]',
    'Protamine sulfate is a positively charged molecule that binds to negatively charged heparin, neutralizing its anticoagulant effect. Vitamin K reverses warfarin. Naloxone reverses opioids. Flumazenil reverses benzodiazepines.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C85C0D1D-E099-4131-961C-6596D141F33E',
    'Which medication class ending in ''-pril'' is used for hypertension and heart failure?',
    'ACE inhibitors (e.g., lisinopril, enalapril)',
    '["Beta blockers", "Calcium channel blockers", "ARBs"]',
    'ACE inhibitors end in ''-pril'' and work by blocking angiotensin-converting enzyme, reducing angiotensin II production. This causes vasodilation and decreased aldosterone, lowering BP. Common side effect is dry cough.',
    'Pharmacology',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0EB45DCB-1C23-4E9C-8C59-0A00E15AECC5',
    'A patient on digoxin has a heart rate of 52 bpm. What should the nurse do?',
    'Hold the medication and notify the provider',
    '["Give the medication as prescribed", "Give half the prescribed dose", "Wait 30 minutes and recheck the heart rate"]',
    'Digoxin slows heart rate. Hold digoxin if HR <60 bpm (adults) or <70 bpm (children) as this may indicate toxicity. Always check apical pulse for full minute before administration. Notify provider for HR below threshold.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D0D10AEA-4822-4473-A79F-658AD471BF09',
    'Which electrolyte imbalance increases the risk of digoxin toxicity?',
    'Hypokalemia (low potassium)',
    '["Hyperkalemia", "Hypernatremia", "Hypercalcemia"]',
    'Digoxin and potassium compete for the same binding sites on the sodium-potassium ATPase pump. Low potassium means more digoxin binds, increasing toxicity risk. Always monitor K+ levels in patients on digoxin.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2AAF8652-41A4-4E1C-9E10-6370E8616F9D',
    'What is the antidote for acetaminophen (Tylenol) overdose?',
    'Acetylcysteine (Mucomyst)',
    '["Naloxone", "Flumazenil", "Protamine sulfate"]',
    'Acetylcysteine replenishes glutathione stores in the liver, which is depleted by the toxic metabolite of acetaminophen (NAPQI). Most effective within 8 hours of overdose but can be given up to 24 hours.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6666B9C1-23B2-4838-8422-CB32DCA67850',
    'A patient is starting metformin for type 2 diabetes. Which teaching is ESSENTIAL?',
    'Hold the medication before procedures using IV contrast dye',
    '["Take on an empty stomach for best absorption", "This medication will cause significant weight gain", "Blood glucose monitoring is not necessary"]',
    'Metformin combined with IV contrast dye can cause lactic acidosis, a life-threatening condition. Hold metformin 48 hours before and after contrast procedures. Metformin should be taken with food to reduce GI upset and typically causes weight loss or neutrality.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9A02E6E2-DBAA-4358-97BF-CAA8FA691064',
    'Which medication requires the patient to avoid grapefruit juice?',
    'Statins (e.g., atorvastatin, simvastatin)',
    '["Acetaminophen", "Amoxicillin", "Omeprazole"]',
    'Grapefruit juice inhibits CYP3A4 enzyme in the intestine, which normally metabolizes statins. This leads to increased statin levels and risk of muscle damage (rhabdomyolysis). Some statins are more affected than others.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6E2A92BC-EB22-40EF-8A26-8A5A037912D6',
    'Select ALL symptoms of opioid overdose:',
    'Respiratory depression, Pinpoint pupils, Decreased level of consciousness, Bradycardia',
    '["Dilated pupils"]',
    'Opioid overdose causes CNS depression: slow/shallow breathing (respiratory depression is the killer), pinpoint (miotic) pupils, decreased LOC/unresponsive, and bradycardia. Dilated pupils suggest stimulant overdose or anticholinergic toxicity.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EA13CBA4-7BEB-4643-B885-D46D369A76FE',
    'Which antibiotic class should be avoided during pregnancy due to effects on fetal teeth and bones?',
    'Tetracyclines',
    '["Penicillins", "Cephalosporins", "Macrolides"]',
    'Tetracyclines cross the placenta and deposit in developing teeth and bones, causing permanent tooth discoloration and potential bone growth problems. Contraindicated in pregnancy and children under 8 years.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '36E36D58-A530-4C25-B4FA-9CEF819FB054',
    'A 2-year-old is admitted with suspected epiglottitis. Which action should the nurse AVOID?',
    'Inspecting the throat with a tongue depressor',
    '["Keeping the child calm", "Having emergency intubation equipment nearby", "Allowing the child to sit in a position of comfort"]',
    'In epiglottitis, the airway is severely compromised. Using a tongue depressor can trigger complete airway obstruction and respiratory arrest. Visualize the throat only in a controlled setting with emergency airway equipment ready.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '74001284-9883-4720-96D3-08EB13117EB9',
    'What is the normal respiratory rate for a newborn?',
    '30-60 breaths per minute',
    '["12-20 breaths per minute", "20-30 breaths per minute", "60-80 breaths per minute"]',
    'Newborns have faster respiratory rates than adults due to higher metabolic demands and smaller lung capacity. Normal newborn RR is 30-60/min. Rates >60/min (tachypnea) may indicate respiratory distress.',
    'Pediatrics',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '37F819A5-2DA4-4481-9FD5-5F8CA65C5EDB',
    'A child is diagnosed with Kawasaki disease. Which assessment finding is MOST concerning?',
    'Coronary artery abnormalities on echocardiogram',
    '["Strawberry tongue", "Peeling skin on fingers", "High fever for 5 days"]',
    'Kawasaki disease causes systemic vasculitis with the most serious complication being coronary artery aneurysms, which can lead to MI, heart failure, and death. IVIG treatment reduces this risk when given within 10 days of fever onset.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'AA009CC8-CD3F-4F6F-B569-FBC487982189',
    'At what age should an infant double their birth weight?',
    '4-6 months',
    '["1-2 months", "8-10 months", "12 months"]',
    'Infants typically double birth weight by 4-6 months and triple it by 12 months. This is an important milestone for assessing adequate nutrition and growth. Failure to meet this may indicate feeding problems or underlying illness.',
    'Pediatrics',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '39194082-F658-4647-AA46-19015EBE81EB',
    'Which finding is expected in a child with pyloric stenosis?',
    'Projectile vomiting after feeding with an olive-shaped mass in the abdomen',
    '["Bile-stained vomiting", "Diarrhea with blood in stool", "Gradual onset of vomiting over several weeks"]',
    'Pyloric stenosis causes hypertrophy of the pyloric sphincter, obstructing gastric outflow. Classic presentation: non-bilious projectile vomiting, visible peristalsis, palpable ''olive'' mass in RUQ, and hungry baby. Usually presents at 2-8 weeks of age.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F98C2DB8-5FC9-4512-B779-A1C4A351EB99',
    'A laboring patient''s fetal heart rate shows late decelerations. What is the nurse''s PRIORITY action?',
    'Reposition the patient to left lateral side and administer oxygen',
    '["Continue to monitor without intervention", "Increase the rate of Pitocin", "Prepare for immediate cesarean section"]',
    'Late decelerations indicate uteroplacental insufficiency (decreased oxygen to fetus). Immediate nursing actions: left lateral position (improves uterine blood flow), oxygen (increases available O2), stop Pitocin if running, IV fluid bolus. Notify provider immediately.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3F06E81D-B30E-4AEE-84E9-97408D18588E',
    'What is the normal fetal heart rate range?',
    '110-160 beats per minute',
    '["60-100 beats per minute", "100-150 beats per minute", "160-200 beats per minute"]',
    'Normal fetal heart rate (FHR) baseline is 110-160 bpm. Below 110 (bradycardia) or above 160 (tachycardia) for >10 minutes requires evaluation. Variability and accelerations are signs of fetal well-being.',
    'Maternity',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9F02F549-38FF-4937-99AE-455A6D1C4ABC',
    'A postpartum patient has a boggy uterus and heavy bleeding. What is the FIRST nursing action?',
    'Massage the uterine fundus',
    '["Administer pain medication", "Call for emergency surgery", "Insert a Foley catheter"]',
    'Uterine atony (boggy uterus) is the most common cause of postpartum hemorrhage. First action is fundal massage to stimulate uterine contraction. Also empty the bladder (full bladder prevents contraction), administer uterotonics as ordered.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D96F2E38-4D49-4700-BC8A-39ABABEFA844',
    'Which symptom is a warning sign of preeclampsia?',
    'Severe headache with visual changes and BP of 160/110',
    '["Mild ankle swelling at end of day", "Occasional Braxton Hicks contractions", "Increased urinary frequency"]',
    'Preeclampsia warning signs: BP ≥140/90, severe headache, visual disturbances (blurring, spots), epigastric pain, sudden edema. Severe preeclampsia (BP ≥160/110) can progress to eclampsia (seizures) and is life-threatening.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C6754B39-7CD5-44A2-81F0-E763E0D68371',
    'When should a pregnant patient feel fetal movement (quickening)?',
    'Primigravida: 18-20 weeks; Multigravida: 16-18 weeks',
    '["8-10 weeks in all pregnancies", "25-28 weeks in all pregnancies", "Only after 30 weeks"]',
    'Quickening (first maternal perception of fetal movement) occurs earlier in multiparous women who recognize the sensation. It''s an important milestone. Decreased fetal movement later in pregnancy warrants evaluation.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B42B63B0-026C-4DAA-B44B-B0F2624B9072',
    'A patient expresses suicidal thoughts. What is the nurse''s PRIORITY assessment?',
    'Ask directly if the patient has a plan and access to means',
    '["Avoid discussing suicide to prevent giving ideas", "Immediately place in physical restraints", "Call family members before talking to patient"]',
    'Direct questioning about suicide does NOT increase risk - it shows concern and allows intervention. Assess: ideation, plan, means, timeline, and protective factors. A specific plan with accessible means = HIGH RISK requiring immediate intervention.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EEDE158B-52AF-44F2-815C-CBCD4896A296',
    'Which therapeutic communication technique involves restating the patient''s message?',
    'Reflection',
    '["Clarification", "Confrontation", "Summarizing"]',
    'Reflection mirrors back the patient''s feelings or content, showing understanding and encouraging elaboration. Example: Patient: ''I''m so angry at my family.'' Nurse: ''You''re feeling angry at your family.'' This validates feelings.',
    'Mental Health',
    'Psychosocial Integrity',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E7FFCC9A-B65D-49C9-A5CD-604CF0097D6D',
    'A patient with schizophrenia reports hearing voices telling them to hurt themselves. What type of hallucination is this?',
    'Command auditory hallucination',
    '["Visual hallucination", "Tactile hallucination", "Olfactory hallucination"]',
    'Command hallucinations are auditory hallucinations that tell the person to do something, often harmful. These require immediate assessment and safety intervention as patients may act on commands. This is a psychiatric emergency.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0B258601-CC80-4B71-8545-4B7705B548FA',
    'Select ALL symptoms of serotonin syndrome:',
    'Hyperthermia, Agitation, Hyperreflexia, Tremor, Diaphoresis',
    '["Hypothermia"]',
    'Serotonin syndrome occurs with excessive serotonergic activity, often from drug interactions (SSRIs + MAOIs, SSRIs + triptans). Symptoms: hyperthermia, altered mental status, autonomic instability, neuromuscular abnormalities. Life-threatening emergency.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F06D31C0-19BE-4ACB-8C28-30CA4997D424',
    'A patient with alcohol use disorder is admitted. When should the nurse expect withdrawal symptoms to begin?',
    '6-24 hours after last drink',
    '["Immediately upon admission", "3-5 days after last drink", "1-2 weeks after last drink"]',
    'Alcohol withdrawal timeline: 6-24 hours - tremors, anxiety, tachycardia; 24-48 hours - hallucinations; 48-72 hours - seizures; 3-5 days - delirium tremens (DTs). DTs have 5-15% mortality if untreated.',
    'Mental Health',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'FBD21EFF-E232-46DE-939A-22E0B08628A5',
    'Which task is appropriate to delegate to a UAP (unlicensed assistive personnel)?',
    'Taking vital signs on a stable patient',
    '["Assessing a new patient''s pain level", "Administering oral medications", "Teaching a patient about new medications"]',
    'UAPs can perform tasks that are routine, standard, and do not require nursing judgment: vital signs, ADLs, ambulation, I&O, feeding stable patients. Assessment, teaching, and medication administration require RN/LPN licensure.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'FD3C206D-C15D-4571-945B-D53422B4ACFB',
    'A nurse receives report on four patients. Which patient should be assessed FIRST?',
    'Post-op patient with increasing restlessness and blood pressure dropping',
    '["Diabetic patient due for morning insulin", "Patient requesting pain medication", "Patient scheduled for discharge teaching"]',
    'Using ABCs and prioritization: the post-op patient with restlessness and dropping BP may be hemorrhaging (shock). This is life-threatening and requires immediate assessment. The other patients are important but stable.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3799958B-7537-4636-99C4-D95CED7351B6',
    'A nurse makes a medication error. What is the FIRST action?',
    'Assess the patient for adverse effects',
    '["Complete an incident report before telling anyone", "Notify the nurse manager", "Call the pharmacy"]',
    'Patient safety is always first. Assess for adverse effects and intervene as needed. Then notify the provider, document objectively in the chart, and complete an incident report. Never delay patient assessment for administrative tasks.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '8FAC685F-0FC2-4155-AF9C-A3DE81071764',
    'What is the purpose of an incident report?',
    'To identify patterns and improve systems to prevent future occurrences',
    '["To punish the nurse who made the error", "To document in the patient''s medical record", "To report the nurse to the state board"]',
    'Incident reports are quality improvement tools, not punitive. They identify system issues and patterns to prevent future errors. They are NOT part of the medical record and should not be referenced in charting.',
    'Leadership',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DF2624D4-9E91-480F-AB10-2BFAD1FA9D68',
    'Which patient can the RN safely assign to an LPN/LVN?',
    'Stable patient with a chronic condition requiring routine care',
    '["New admission requiring comprehensive assessment", "Patient requiring blood transfusion", "Unstable patient requiring frequent reassessment"]',
    'LPN/LVNs work under RN supervision and can care for stable, predictable patients. They can administer most medications (varies by state), perform treatments, and reinforce teaching. New admissions, unstable patients, and blood transfusions require RN assessment skills.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '910E0A44-62E2-4569-B37E-FBDFBBCCCB6E',
    'A patient with acute pancreatitis is NPO. What is the PRIMARY reason?',
    'To rest the pancreas by reducing stimulation of pancreatic enzyme secretion',
    '["To prepare for emergency surgery", "To prevent aspiration", "To reduce caloric intake"]',
    'Eating stimulates pancreatic enzyme secretion, worsening inflammation. NPO status allows the pancreas to rest and heal. Nutrition is provided via TPN or jejunal feeding if prolonged NPO is needed.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B01736E4-E1A5-442D-9382-A2D58A5B4E6F',
    'What is the PRIORITY assessment for a patient receiving a blood transfusion?',
    'Monitor for signs of transfusion reaction in the first 15-30 minutes',
    '["Check blood glucose levels", "Assess pain level", "Measure urine output hourly"]',
    'Most severe transfusion reactions (hemolytic, anaphylactic) occur within the first 15-30 minutes. Stay with patient, monitor vital signs every 5-15 minutes initially. Signs: fever, chills, back pain, hypotension, dyspnea.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1A071761-80AB-47CA-8547-415B420B1279',
    'A patient has a chest tube connected to water-seal drainage. Which finding requires immediate action?',
    'Continuous bubbling in the water-seal chamber',
    '["Tidaling in the water-seal chamber during respirations", "Drainage of 50 mL serous fluid in the past hour", "The drainage system positioned below the chest level"]',
    'Continuous bubbling indicates an air leak - either in the patient (pneumothorax not resolved) or in the system (loose connection). Tidaling is normal and shows the system is patent. The system should be below chest level.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'AB75DD3A-512E-4F01-98CC-989E7BB92968',
    'A patient with Addison''s disease is in crisis. Which intervention is PRIORITY?',
    'Administer IV corticosteroids and fluids as ordered',
    '["Restrict sodium intake", "Administer insulin", "Place in Trendelenburg position"]',
    'Addisonian crisis is life-threatening adrenal insufficiency. Treatment: IV hydrocortisone (replaces deficient cortisol), IV fluids (for hypotension/dehydration), correct electrolytes. These patients need MORE sodium, not restriction.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '52ACF02C-2783-4E30-8083-144BEAE21ABC',
    'Which patient is at HIGHEST risk for developing pressure injuries?',
    'Elderly patient who is bedbound, incontinent, and has poor nutritional intake',
    '["Young athlete recovering from knee surgery", "Middle-aged patient admitted for observation", "Ambulatory patient with well-controlled diabetes"]',
    'Pressure injury risk factors: immobility, moisture (incontinence), poor nutrition, advanced age, decreased sensation. Use Braden Scale to assess risk. Prevention includes repositioning every 2 hours, moisture management, nutrition optimization.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '08AE3368-6E52-4E59-8EF4-DC84F0BB0DB7',
    'A patient is diagnosed with SIADH. Which finding should the nurse expect?',
    'Hyponatremia with concentrated urine',
    '["Hypernatremia with dilute urine", "Normal sodium with polyuria", "Hyperkalemia with oliguria"]',
    'SIADH causes excess ADH secretion, leading to water retention and dilutional hyponatremia. Urine is concentrated (high specific gravity) despite low serum sodium. Treatment: fluid restriction, hypertonic saline for severe cases.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DD4106A4-0074-4F12-AD5C-14F9410E89BE',
    'A patient with myasthenia gravis develops respiratory distress. What should the nurse suspect?',
    'Myasthenic or cholinergic crisis',
    '["Pulmonary embolism", "Asthma exacerbation", "Pneumonia"]',
    'Both crises cause respiratory failure. Myasthenic crisis = undertreated disease; Cholinergic crisis = overmedication with anticholinesterase. Edrophonium (Tensilon) test differentiates: improvement = myasthenic crisis; worsening = cholinergic crisis.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E6E22266-A46B-42AB-AE31-954B99EED2BB',
    'What is the FIRST sign of increased intracranial pressure (ICP)?',
    'Change in level of consciousness',
    '["Cushing''s triad", "Pupil changes", "Projectile vomiting"]',
    'LOC changes (confusion, lethargy, restlessness) are the earliest and most sensitive indicator of rising ICP. Cushing''s triad (hypertension, bradycardia, irregular respirations) is a late sign indicating brainstem herniation.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4A896D6B-44C9-4162-88B8-47DD8B707C20',
    'A patient has a pH of 7.30, PaCO2 of 55, and HCO3 of 26. What is the acid-base imbalance?',
    'Respiratory acidosis (uncompensated)',
    '["Metabolic acidosis", "Respiratory alkalosis", "Metabolic alkalosis"]',
    'pH <7.35 = acidosis. High CO2 (>45) indicates respiratory cause. Normal HCO3 (22-26) shows no metabolic compensation yet. ROME: Respiratory Opposite (pH and CO2 move opposite in respiratory disorders), Metabolic Equal.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A3E3723B-B2A5-48D1-922A-74AE6D23F0F4',
    'Select ALL interventions appropriate for a patient with acute kidney injury (AKI):',
    'Monitor strict I&O, Weigh daily, Restrict potassium and sodium, Monitor for fluid overload',
    '["Encourage high-protein diet"]',
    'AKI requires careful fluid and electrolyte management. Monitor I&O and daily weights to assess fluid status. Restrict K+ (kidneys can''t excrete), restrict Na+ and fluid if oliguric. Moderate protein restriction reduces BUN. Watch for fluid overload and hyperkalemia.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '135B4A5D-E428-4159-985A-D81282184647',
    'A patient on lithium has a level of 2.0 mEq/L. What should the nurse do FIRST?',
    'Hold the lithium and notify the provider immediately',
    '["Administer the next scheduled dose", "Encourage increased fluid intake", "Document and continue to monitor"]',
    'Therapeutic lithium level is 0.6-1.2 mEq/L. Level of 2.0 is toxic. Symptoms: severe GI distress, tremors, confusion, seizures. Hold medication, notify provider, prepare for possible dialysis. Ensure adequate hydration and sodium intake.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A1649A28-AA5F-4002-8C24-A4799575A90C',
    'Which instruction should the nurse give a patient taking MAOIs?',
    'Avoid aged cheeses, cured meats, and wine to prevent hypertensive crisis',
    '["Take with grapefruit juice to enhance absorption", "Expect significant weight loss", "Discontinue abruptly when feeling better"]',
    'MAOIs prevent breakdown of tyramine. Foods high in tyramine (aged cheese, wine, cured meats, soy sauce) cause severe hypertension (hypertensive crisis). Patient must follow dietary restrictions for 2 weeks after stopping MAOI.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4EC74583-61DF-4B1F-AFE8-82E48BD4F24F',
    'What is the mechanism of action of beta-blockers (medications ending in ''-olol'')?',
    'Block beta-adrenergic receptors, decreasing heart rate and blood pressure',
    '["Block calcium channels in the heart", "Inhibit ACE enzyme", "Directly dilate blood vessels"]',
    'Beta-blockers block beta-1 receptors (heart) reducing HR, contractility, and BP. Beta-2 blockade can cause bronchoconstriction (caution in asthma/COPD). Never stop abruptly - taper to prevent rebound hypertension.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '25CB1B7A-788C-4806-B307-65E9576736D1',
    'A patient is starting amiodarone. Which baseline test is ESSENTIAL?',
    'Thyroid function tests, liver function tests, and pulmonary function tests',
    '["Renal function only", "Complete blood count only", "Blood glucose levels"]',
    'Amiodarone can cause thyroid dysfunction (hypo or hyper due to iodine content), hepatotoxicity, and pulmonary fibrosis. Baseline and periodic monitoring of thyroid, liver, and lungs is essential. Also causes corneal deposits and photosensitivity.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '90A338E6-CA7A-4C8D-AC9C-1DDBFF4545DF',
    'Which medication requires monitoring for gray baby syndrome in neonates?',
    'Chloramphenicol',
    '["Amoxicillin", "Cephalexin", "Azithromycin"]',
    'Neonates lack glucuronyl transferase enzyme to metabolize chloramphenicol. Accumulation causes gray baby syndrome: abdominal distension, vomiting, gray skin color, cardiovascular collapse. Rarely used due to this risk and aplastic anemia.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '33974BBE-91AD-4697-816A-2E00EEE996DB',
    'What is the antidote for magnesium sulfate toxicity?',
    'Calcium gluconate',
    '["Protamine sulfate", "Vitamin K", "Flumazenil"]',
    'Magnesium sulfate (used for preeclampsia/eclampsia and preterm labor) toxicity causes respiratory depression, absent reflexes, cardiac arrest. Calcium gluconate reverses effects. Monitor: DTRs, respiratory rate (>12), urine output (>30 mL/hr).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5A0380C1-F042-4316-B15D-ABC35241196E',
    'Select ALL medications that require renal dose adjustment:',
    'Vancomycin, Metformin, Gabapentin, Enoxaparin',
    '["Acetaminophen"]',
    'Renally cleared drugs accumulate in kidney dysfunction. Vancomycin requires trough monitoring. Metformin is contraindicated in severe renal impairment (lactic acidosis risk). Gabapentin and enoxaparin need dose reduction. Many antibiotics require adjustment.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'ECF670DD-3234-4CE7-8485-A180B7DD4218',
    'Which assessment is MOST important before administering potassium IV?',
    'Verify adequate urine output (at least 30 mL/hr)',
    '["Check blood glucose level", "Assess pain level", "Verify last bowel movement"]',
    'Potassium is excreted by the kidneys. Giving IV K+ to a patient with inadequate urine output can cause fatal hyperkalemia. Also: never give IV push, use infusion pump, max concentration and rate per protocol, cardiac monitor for high doses.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EC1A8A36-6914-492F-AC8A-EDFFF7E7F2AE',
    'A child with cystic fibrosis is prescribed pancreatic enzymes. When should these be given?',
    'With meals and snacks',
    '["Only at bedtime", "2 hours before meals", "Only when experiencing symptoms"]',
    'Pancreatic enzymes (pancrelipase) replace deficient digestive enzymes in CF. Must be taken with ALL meals and snacks to digest fats and proteins. Without enzymes, nutrients pass through undigested causing malnutrition and steatorrhea.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '61AE72A0-C0BF-47BD-AE91-E05C892E3F72',
    'What is the classic triad of symptoms in a child with intussusception?',
    'Colicky abdominal pain, vomiting, and currant jelly stools',
    '["Fever, rash, and joint pain", "Cough, wheeze, and fever", "Headache, vomiting, and stiff neck"]',
    'Intussusception is telescoping of intestine, causing obstruction. Classic triad: intermittent severe colicky pain (child draws up knees), vomiting, and ''currant jelly'' stools (blood and mucus). Medical emergency - requires air/barium enema or surgery.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '168BCEA0-5F73-42FD-832B-8B95CCE90E11',
    'Which immunization is contraindicated for a child with severe egg allergy?',
    'Influenza vaccine (injection form)',
    '["MMR vaccine", "Hepatitis B vaccine", "DTaP vaccine"]',
    'Influenza vaccine is grown in eggs and may contain egg protein. Severe egg allergy requires observation after vaccination or use of egg-free alternatives. MMR is grown in chick embryo fibroblasts (not egg) and is safe for egg-allergic children.',
    'Pediatrics',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0E9086C3-06DB-4046-ABF1-743B478F6115',
    'A child is diagnosed with acute glomerulonephritis. Which findings should the nurse expect?',
    'Periorbital edema, dark-colored urine, and hypertension',
    '["Polyuria and weight loss", "Hypotension and pale urine", "Increased appetite and fever"]',
    'Post-streptococcal glomerulonephritis (usually follows strep throat) causes: edema (especially periorbital in AM), tea/cola-colored urine (hematuria), hypertension, and oliguria. Treat underlying infection, manage symptoms, usually self-limiting.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '46443298-B4A2-461F-B6B9-4D08B4AE4A85',
    'What is the PRIORITY nursing intervention for a child in sickle cell crisis?',
    'Administer pain medication and IV fluids',
    '["Apply ice to affected areas", "Restrict fluids", "Encourage deep breathing exercises only"]',
    'Vaso-occlusive crisis causes severe pain from sickling and vessel occlusion. PRIORITY: aggressive pain management (often opioids), hydration (helps prevent further sickling), oxygen if hypoxic. Heat (not ice) may help. Avoid cold and dehydration.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0DF13D35-57F2-4937-9A6A-6F41E05C6F53',
    'A pregnant patient at 28 weeks has Rh-negative blood. When should RhoGAM be administered?',
    'At 28 weeks gestation and within 72 hours after delivery if baby is Rh-positive',
    '["Only after delivery", "Only if antibodies are present", "At every prenatal visit"]',
    'RhoGAM prevents Rh sensitization. Given at 28 weeks (when fetal cells may enter maternal circulation) and within 72 hours postpartum if baby is Rh-positive. Also given after any bleeding, amniocentesis, or trauma during pregnancy.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9702D9EF-7E41-488C-89D3-71D756985F80',
    'What is the expected fundal height at 20 weeks gestation?',
    'At the level of the umbilicus',
    '["Just above the symphysis pubis", "Halfway between umbilicus and xiphoid", "At the xiphoid process"]',
    'Fundal height in cm approximately equals gestational age in weeks (McDonald''s rule). At 20 weeks, fundus is at umbilicus. At 36 weeks, at xiphoid. After 36 weeks, may drop as baby engages. Discrepancy may indicate multiple gestation, IUGR, or wrong dates.',
    'Maternity',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5A38B79C-F20F-4A65-A44F-8857671A0C57',
    'A patient in labor has an umbilical cord prolapse. What is the PRIORITY nursing action?',
    'Elevate the presenting part off the cord and call for emergency cesarean',
    '["Push the cord back into the vagina", "Apply oxygen and wait for spontaneous delivery", "Have the patient push to expedite delivery"]',
    'Cord prolapse is an emergency - compression causes fetal hypoxia/death. Position: knee-chest or Trendelenburg. Use gloved hand to elevate presenting part off cord. Do NOT attempt to replace cord. Emergency cesarean is usually needed.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DD854C13-3B56-44A8-AFFB-6AF3A7620488',
    'What does a Bishop score assess?',
    'Cervical readiness for induction of labor',
    '["Fetal lung maturity", "Risk of cesarean section", "Neonatal well-being after delivery"]',
    'Bishop score evaluates: cervical dilation, effacement, station, consistency, and position. Score ≥8 indicates favorable cervix likely to respond to induction. Lower scores may need cervical ripening agents (prostaglandins) before oxytocin.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F4CA5E07-5495-41AF-8343-271863058128',
    'Select ALL warning signs of postpartum depression that require intervention:',
    'Thoughts of harming self or baby, Inability to care for baby, Persistent crying and hopelessness, Severe anxiety or panic attacks',
    '["Mild mood swings in first 2 weeks"]',
    'Postpartum ''blues'' (mild mood swings, tearfulness) is normal in first 2 weeks. PPD is more severe and persistent: prolonged sadness, inability to function, sleep/appetite changes, thoughts of harm. PPD requires treatment. Postpartum psychosis is psychiatric emergency.',
    'Maternity',
    'Psychosocial Integrity',
    'Medium',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7E782470-E58E-40B8-B99E-0DD48AA9EF51',
    'A patient with bipolar disorder is in a manic episode. Which intervention is MOST appropriate?',
    'Provide a calm, low-stimulation environment with consistent boundaries',
    '["Encourage participation in group activities", "Allow the patient to make all decisions", "Engage in lengthy conversations about behavior"]',
    'During mania, patients are easily overstimulated, have poor judgment, and need structure. Reduce stimuli, set clear limits, provide high-calorie finger foods (they won''t sit to eat), ensure safety. Redirect rather than argue.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5BB3B6FD-A5D4-4885-A0E2-AA8BF3FCE716',
    'Which defense mechanism is demonstrated when a patient diagnosed with cancer says ''The lab must have made a mistake''?',
    'Denial',
    '["Projection", "Rationalization", "Displacement"]',
    'Denial is refusing to accept reality as a way to cope with overwhelming information. It''s often a first response to bad news and can be protective initially. Denial becomes problematic when it prevents necessary treatment or coping.',
    'Mental Health',
    'Psychosocial Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7A0F5E0A-6B3B-41D2-ABFE-9F7B664EDA79',
    'A patient with anorexia nervosa is admitted with a BMI of 14. What is the PRIORITY concern?',
    'Cardiac arrhythmias due to electrolyte imbalances',
    '["Body image disturbance", "Family dynamics", "Self-esteem issues"]',
    'Severe anorexia causes life-threatening electrolyte imbalances (especially hypokalemia) leading to fatal arrhythmias. Medical stabilization is priority before psychological treatment. Refeeding syndrome is also a risk - reintroduce nutrition slowly.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'ED59F72B-2756-46B6-BFA9-1DFD4C9E7F2B',
    'What is the FIRST-LINE treatment for mild to moderate depression?',
    'SSRIs (Selective Serotonin Reuptake Inhibitors)',
    '["MAOIs", "Tricyclic antidepressants", "Electroconvulsive therapy"]',
    'SSRIs (fluoxetine, sertraline, etc.) are first-line due to favorable side effect profile and safety in overdose compared to older antidepressants. Takes 2-4 weeks for full effect. MAOIs require dietary restrictions. TCAs have cardiac risks.',
    'Mental Health',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B9A1530A-B6DF-4423-9167-132316C38307',
    'A patient with PTSD avoids all reminders of their trauma. This is an example of which symptom cluster?',
    'Avoidance symptoms',
    '["Intrusion symptoms", "Arousal symptoms", "Negative cognition symptoms"]',
    'PTSD has 4 symptom clusters: Intrusion (flashbacks, nightmares), Avoidance (avoiding triggers, emotional numbing), Negative cognitions (guilt, detachment), and Arousal (hypervigilance, startle response, sleep problems). All must be present for diagnosis.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7C86FC02-B66C-4350-A507-486BA3BFE21D',
    'A nurse suspects a colleague is diverting controlled substances. What is the APPROPRIATE action?',
    'Report concerns to the nurse manager or appropriate authority',
    '["Confront the colleague directly", "Ignore it to avoid conflict", "Search the colleague''s belongings"]',
    'Nurses have an ethical and legal obligation to report suspected impairment or diversion. Follow facility policy - typically report to manager or compliance. Documentation of observed behaviors is important. Do not investigate independently.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '401D1B37-8B83-4AD1-B1A6-21CEFF411B1A',
    'Which situation represents a HIPAA violation?',
    'Discussing a patient''s diagnosis in the hospital elevator',
    '["Sharing patient information with the treatment team", "Giving report to the oncoming nurse", "Documenting assessment findings in the chart"]',
    'HIPAA protects patient privacy. Violations include: discussing patients in public areas, accessing records without need, sharing login credentials, leaving PHI visible. Sharing with treatment team and documentation are appropriate and necessary.',
    'Leadership',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '129B98F8-E7CC-4BA4-B0BD-6D8C94119CC4',
    'A nursing student asks to observe a procedure. What must occur FIRST?',
    'Obtain the patient''s consent for the student''s presence',
    '["Allow observation without discussion", "Have the student introduce themselves after the procedure", "Document that a student was present"]',
    'Patient autonomy and privacy require consent before allowing students to observe or participate in care. The patient has the right to refuse. Introduce the student, explain their role, and obtain verbal consent. Document appropriately.',
    'Leadership',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F9985B2B-518A-40BF-B55F-1725ECFC9C2C',
    'What is the nurse''s responsibility when receiving an unclear or potentially harmful order?',
    'Clarify the order with the prescriber before acting',
    '["Carry out the order as written", "Ignore the order", "Have another nurse carry out the order"]',
    'Nurses are legally and ethically obligated to question orders that are unclear, incomplete, or potentially harmful. Clarify directly with prescriber. If still concerned, escalate through chain of command. Document communication.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C07047A3-FB88-4A0A-B59A-E119392A98B9',
    'Which isolation precaution is required for a patient with tuberculosis?',
    'Airborne precautions with N95 respirator',
    '["Contact precautions only", "Droplet precautions with surgical mask", "Standard precautions only"]',
    'TB spreads via airborne droplet nuclei (<5 microns) that remain suspended in air. Requires: private negative-pressure room, N95 respirator (fit-tested), patient wears surgical mask during transport. Healthcare workers need annual TB testing.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0773C110-3C3B-4F92-9625-249D19539DBC',
    'What is the CORRECT order for donning PPE?',
    'Gown, mask/respirator, goggles/face shield, gloves',
    '["Gloves, gown, mask, goggles", "Mask, gloves, gown, goggles", "Goggles, gloves, mask, gown"]',
    'Donning sequence protects from contamination: Gown first (ties in back), then mask/respirator (requires both hands), eye protection, gloves last (cover gown cuffs). Removal is reverse, with gloves first (most contaminated).',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A9EACD4D-39BF-4D6C-AFA9-2BBE021DABCC',
    'A patient has C. difficile infection. Which precautions are required?',
    'Contact precautions with hand washing (not alcohol-based sanitizer)',
    '["Droplet precautions only", "Airborne precautions", "Standard precautions only"]',
    'C. diff spores are NOT killed by alcohol-based sanitizers - must wash hands with soap and water. Contact precautions: gown and gloves, dedicated equipment. C. diff is spread by fecal-oral route. Strict environmental cleaning with sporicidal agents.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B07E3BA1-399F-4947-ADCC-4A5194B0B8B9',
    'Select ALL conditions requiring droplet precautions:',
    'Influenza, Pertussis, Meningococcal meningitis, Mumps',
    '["Tuberculosis"]',
    'Droplet precautions for pathogens spread by large droplets (>5 microns) that travel <6 feet: influenza, pertussis, meningococcal disease, mumps, rubella. Require surgical mask within 6 feet. Private room preferred. TB requires airborne precautions.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '15D12433-D93B-449D-9101-BDC42F593DA3',
    'How long should surgical hand scrub be performed?',
    '3-5 minutes with systematic scrubbing of hands and forearms',
    '["15 seconds", "30 seconds", "10 minutes"]',
    'Surgical hand antisepsis requires longer contact time than routine hand hygiene. Scrub hands and forearms to 2 inches above elbows using systematic pattern. Keep hands elevated. Dry with sterile towel. Some facilities use alcohol-based surgical scrubs.',
    'Infection Control',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'AF5780BB-12AC-4EDC-8075-F7A8E0B61C38',
    'A patient is receiving PCA morphine. Which assessment indicates potential oversedation?',
    'Respiratory rate of 8 and difficult to arouse',
    '["Pain rating of 3/10", "Drowsy but easily arousable", "Requesting increased PCA dose"]',
    'Sedation precedes respiratory depression with opioids. Use sedation scale: Level 3 (difficult to arouse) or RR <10 requires immediate intervention. Hold PCA, stimulate patient, administer naloxone if ordered, notify provider.',
    'Safety',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9587B70E-46B9-4EE7-9D48-EFB22F2304FE',
    'Which finding indicates a patient is at HIGH risk for aspiration?',
    'Absent gag reflex and difficulty swallowing',
    '["Intact cough reflex", "Alert and oriented", "Taking small sips of water without difficulty"]',
    'Aspiration risk factors: decreased LOC, absent gag reflex, dysphagia, stroke, NG tube, mechanical ventilation. Prevention: elevate HOB 30-45°, assess swallow before oral intake, proper positioning, suction available.',
    'Safety',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EE68040D-23C9-4E81-A974-530B211F2196',
    'What is the nurse''s FIRST action when a fire alarm sounds?',
    'Implement RACE: Rescue patients in immediate danger',
    '["Continue current activities until notified", "Evacuate all patients immediately", "Call the fire department"]',
    'RACE: Rescue patients in immediate danger, Activate alarm (if not already), Contain fire (close doors), Extinguish (if small and safe) or Evacuate. Patients closest to fire rescued first. Know fire exits and extinguisher locations.',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6FE6B5A9-26D1-416C-8978-5724AB7D5BAC',
    'A patient has a latex allergy. Which items should the nurse AVOID?',
    'Latex gloves, urinary catheters with latex, and some adhesive bandages',
    '["Vinyl gloves", "Silicone-based products", "Non-latex tourniquets"]',
    'Latex allergy ranges from skin irritation to anaphylaxis. Avoid: latex gloves, catheters, tourniquets, some adhesives. Use latex-free alternatives (nitrile, vinyl gloves; silicone catheters). Also note cross-reactivity with certain foods (bananas, kiwi, avocado).',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EC55EFD3-9332-4912-8424-BC61C2788F67',
    'Which patient is at HIGHEST priority for discharge teaching before leaving the hospital?',
    'Patient going home on new anticoagulant therapy',
    '["Patient with well-controlled chronic hypertension", "Patient with unchanged home medications", "Patient with home health nurse visits scheduled"]',
    'New anticoagulants require extensive teaching: signs of bleeding, dietary interactions (warfarin/vitamin K), drug interactions, lab monitoring schedule, when to seek emergency care. Improper use can cause serious bleeding or clots.',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DD54E648-9583-4615-8F64-0F9FD6B25584',
    'A patient with a tracheostomy is having difficulty breathing. What should the nurse do FIRST?',
    'Suction the tracheostomy tube',
    '["Remove the tracheostomy tube", "Administer oxygen via nasal cannula", "Call a code blue"]',
    'Mucus plugging is the most common cause of respiratory distress in tracheostomy patients. First action is suctioning to clear the airway. If suctioning doesn''t help, assess tube position, deflate cuff if present, and be prepared to change tube if obstructed.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4648323E-B9BD-4057-960B-9B04D1C804D1',
    'What is the nurse''s PRIORITY when caring for a patient after a lumbar puncture?',
    'Keep the patient flat and monitor for headache and signs of infection',
    '["Encourage immediate ambulation", "Restrict fluids", "Apply ice to the puncture site"]',
    'Post-LP care: flat position for 4-6 hours reduces headache risk from CSF leak. Encourage fluids. Monitor for headache (worse when upright), signs of infection, neurological changes. Headache treatment: bed rest, fluids, caffeine, blood patch if severe.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '200829A4-CBEF-461E-971C-B21EDE6AFBF0',
    'A patient with heart failure is prescribed furosemide (Lasix). Which finding indicates the medication is effective?',
    'Decreased peripheral edema and weight loss',
    '["Weight gain", "Increased blood pressure", "Decreased urine output"]',
    'Furosemide is a loop diuretic that removes excess fluid. Effectiveness shown by: decreased edema, weight loss (fluid loss), increased urine output, improved breathing, decreased JVD. Monitor potassium - furosemide causes hypokalemia.',
    'Pharmacology',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5458D4A9-1207-4871-9392-72719EC0A2FE',
    'Which vaccine can be given to an immunocompromised patient?',
    'Inactivated influenza vaccine',
    '["MMR vaccine", "Varicella vaccine", "Live attenuated influenza vaccine (nasal spray)"]',
    'Immunocompromised patients should NOT receive live vaccines (MMR, varicella, live influenza, oral polio). Inactivated vaccines (injection flu, tetanus, hepatitis B, pneumococcal) are safe. Live vaccines can cause disease in immunocompromised hosts.',
    'Fundamentals',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '73E7AE91-6A90-4E53-8765-4093C1231E40',
    'A nurse is teaching a patient about preventing DVT during a long flight. Which instruction is MOST important?',
    'Perform ankle circles and walk periodically',
    '["Keep legs crossed for comfort", "Limit fluid intake to avoid bathroom trips", "Wear tight clothing for support"]',
    'Virchow''s triad: stasis, hypercoagulability, vessel damage. Long periods of immobility cause venous stasis. Prevention: ankle exercises, walking, hydration, loose clothing. Compression stockings for high-risk patients. Avoid crossing legs.',
    'Med-Surg',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4CC7B1F8-D408-4C61-A39B-CEC7C20EECA3',
    'What is the correct technique for administering insulin using a pen?',
    'Prime the pen, inject at 90-degree angle, hold for 10 seconds after injection',
    '["Inject at 45-degree angle without priming", "Remove needle immediately after injection", "Massage the site vigorously after injection"]',
    'Insulin pen technique: prime 2 units before first use/after needle change, clean site, inject at 90° (45° if thin), depress plunger slowly, hold 10 seconds to ensure full dose delivery. Don''t massage. Rotate sites within same region.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '494B44F8-D9CA-4FEB-BA7F-238644506973',
    'A child is admitted with severe dehydration. Which finding is expected?',
    'Sunken fontanels, decreased skin turgor, and tachycardia',
    '["Bulging fontanels and bradycardia", "Excessive tearing and wet diapers", "Slow capillary refill and low blood pressure only"]',
    'Dehydration signs: sunken fontanels (in infants), decreased skin turgor (tenting), tachycardia, dry mucous membranes, decreased tears/urine, prolonged cap refill, eventually hypotension. Severity guides treatment (oral vs IV rehydration).',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4263DF53-E3A6-4188-9C80-06F7326500B0',
    'A newborn has a positive Ortolani sign. What does this indicate?',
    'Developmental dysplasia of the hip (DDH)',
    '["Normal hip development", "Congenital heart defect", "Clubfoot deformity"]',
    'Ortolani test: examiner abducts flexed hips, feeling for ''clunk'' as femoral head relocates into acetabulum (positive = hip was dislocated). Barlow test does opposite (adduction dislocates). DDH treatment: Pavlik harness to keep hips in proper position.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'FEFBC581-41C3-4CCA-8A55-B2AF8FEE3E13',
    'Which assessment finding in a pregnant patient suggests placental abruption?',
    'Painful vaginal bleeding with a rigid, board-like abdomen',
    '["Painless bright red bleeding", "Bloody show with regular contractions", "Leaking clear fluid without bleeding"]',
    'Placental abruption: premature separation of placenta from uterus. Signs: painful bleeding (may be concealed), rigid/tender uterus, fetal distress. Emergency - can cause maternal hemorrhage and fetal death. Placenta previa is painless bleeding.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F237A50F-283B-46DB-B19A-D3FE1930C0C8',
    'A patient with depression has not responded to two different SSRIs. Which treatment might be considered next?',
    'Augmentation therapy or switching to a different medication class',
    '["Continue the same SSRI indefinitely", "Stop all medications immediately", "Increase SSRI to toxic levels"]',
    'Treatment-resistant depression (no response to 2+ adequate trials) options: augment with lithium/atypical antipsychotic/thyroid hormone, switch classes (SNRI, bupropion, TCA, MAOI), or consider ECT. Never stop antidepressants abruptly - taper slowly.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '544E1DDB-F0C9-459C-B396-B7ECD949D3E3',
    'What is the MOST important factor when applying physical restraints?',
    'Use the least restrictive device for the shortest time necessary',
    '["Apply restraints as tight as possible", "Check restraints every 4 hours", "Apply to all four extremities for safety"]',
    'Restraints are a last resort for patient safety. Least restrictive, shortest duration. Physician order required, renewed every 24 hours (varies). Check circulation and release every 2 hours for toileting, ROM, nutrition. Document behavior, alternatives tried.',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4721BCE2-B295-46D9-9A7B-346C035F3B5A',
    'Select ALL components of the Glasgow Coma Scale:',
    'Eye opening response, Verbal response, Motor response',
    '["Pupil response"]',
    'GCS assesses LOC: Eye opening (4 points max), Verbal response (5 points max), Motor response (6 points max). Total: 15 (fully conscious) to 3 (deep coma). Score ≤8 generally indicates severe brain injury and need for airway protection.',
    'Med-Surg',
    'Physiological Integrity',
    'Easy',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3FF4FD8A-6CD6-410B-B1E2-8E4FA633CC28',
    'A patient with cirrhosis develops asterixis. What does this indicate?',
    'Hepatic encephalopathy',
    '["Alcohol withdrawal", "Hypoglycemia", "Hypokalemia"]',
    'Asterixis (liver flap) is a flapping tremor of the hands when arms are extended. It indicates elevated ammonia levels affecting the brain. Treatment includes lactulose to reduce ammonia absorption and protein restriction.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7EE7EDFF-EECD-4020-9905-8C5EFB7C736B',
    'What is the PRIORITY nursing action for a patient with suspected pulmonary embolism?',
    'Administer oxygen and notify the provider immediately',
    '["Encourage deep breathing exercises", "Ambulate the patient", "Apply compression stockings"]',
    'PE is life-threatening. Priority: high-flow O2, maintain airway, IV access, prepare for anticoagulation. Never ambulate - may dislodge more clots. Classic signs: sudden dyspnea, chest pain, tachycardia, anxiety.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1F162A7C-C4BC-40B0-AB35-42E75599B4CA',
    'A patient with heart failure is prescribed furosemide. Which lab value requires monitoring?',
    'Potassium level',
    '["Calcium level", "Sodium level", "Magnesium level"]',
    'Furosemide (Lasix) is a loop diuretic that causes potassium loss. Monitor for hypokalemia (weakness, arrhythmias, muscle cramps). Normal K: 3.5-5.0 mEq/L. May need potassium supplements or potassium-sparing diuretic.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6739810F-557B-4292-87B3-EF68B9EA4B88',
    'A patient post-thyroidectomy reports tingling around the mouth. What should the nurse assess?',
    'Chvostek''s and Trousseau''s signs for hypocalcemia',
    '["Blood glucose level", "Oxygen saturation", "Pupil response"]',
    'Parathyroid glands may be damaged during thyroidectomy, causing hypocalcemia. Perioral tingling is early sign. Chvostek''s: facial twitch when cheek tapped. Trousseau''s: carpal spasm with BP cuff. Have calcium gluconate available.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '69DA068A-BB66-494D-9558-2904C1A9969B',
    'Which position is BEST for a patient with increased intracranial pressure?',
    'Head of bed elevated 30 degrees with head midline',
    '["Flat with legs elevated", "Trendelenburg position", "Side-lying with head flexed"]',
    'HOB 30° promotes venous drainage from brain, reducing ICP. Head midline prevents jugular vein compression. Avoid neck flexion, hip flexion >90°, prone position. These all increase ICP.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A5BCC32C-7E65-4E21-A006-C081238C476B',
    'A patient with COPD has oxygen ordered. What is the safe flow rate?',
    '1-2 L/min via nasal cannula',
    '["6-10 L/min via face mask", "15 L/min via non-rebreather", "4-5 L/min via nasal cannula"]',
    'COPD patients rely on hypoxic drive to breathe. High O2 removes this drive, causing respiratory depression. Target SpO2: 88-92%. Start low (1-2 L) and titrate carefully. Monitor for CO2 retention.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '503BC25A-70A5-4337-B99A-CDA23969E463',
    'What is the antidote for heparin overdose?',
    'Protamine sulfate',
    '["Vitamin K", "Fresh frozen plasma", "Naloxone"]',
    'Protamine sulfate reverses heparin by binding to it. 1 mg protamine neutralizes ~100 units heparin. Vitamin K is antidote for warfarin. Give slowly - rapid infusion causes hypotension, bradycardia.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DE323A68-7281-4CC5-A89F-ED2E9D3EF0CA',
    'A patient with diabetes has a blood glucose of 45 mg/dL. What is the FIRST action?',
    'Give 15-20 grams of fast-acting carbohydrate',
    '["Administer insulin", "Call the physician", "Check ketones"]',
    'Rule of 15: Give 15g fast-acting carbs (4 oz juice, glucose tablets), wait 15 min, recheck. If still <70, repeat. If unconscious, give glucagon IM or IV dextrose. Never give food/drink to unconscious patient.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1A2BBAC7-5F6B-40DE-A735-0BD3A3A6EFE6',
    'Which sign indicates a patient is experiencing digoxin toxicity?',
    'Visual disturbances with yellow-green halos',
    '["Elevated blood pressure", "Increased appetite", "Hyperactivity"]',
    'Digoxin toxicity signs: visual changes (yellow-green halos, blurred vision), GI symptoms (anorexia, nausea, vomiting), bradycardia, arrhythmias. Check level (therapeutic: 0.5-2.0 ng/mL) and potassium (hypokalemia increases toxicity).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9F3893A0-BF5A-44BA-A1BF-4DCE8CEFAA6A',
    'A patient with acute MI is diaphoretic with crushing chest pain. Which medication is given FIRST?',
    'Aspirin 325 mg chewed',
    '["Morphine IV", "Nitroglycerin sublingual", "Metoprolol"]',
    'MONA for MI: Morphine, Oxygen, Nitroglycerin, Aspirin. But Aspirin is actually given FIRST - inhibits platelet aggregation immediately. Chewing speeds absorption. Contraindicated if aspirin allergy or active bleeding.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E8734069-A675-4DF3-88B4-86BB506FF9D2',
    'What assessment finding indicates compartment syndrome?',
    'Pain out of proportion to injury, especially with passive stretch',
    '["Warm, pink extremity", "Strong distal pulses", "Normal capillary refill"]',
    '6 P''s of compartment syndrome: Pain (severe, with passive stretch), Pressure, Paresthesia, Pallor, Pulselessness (late), Paralysis (late). Medical emergency - fasciotomy needed within 6 hours to prevent permanent damage.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A0666DDD-2AC2-4370-A99F-334137E800E8',
    'A patient with a hip fracture is at risk for which life-threatening complication?',
    'Fat embolism syndrome',
    '["Urinary retention", "Constipation", "Skin breakdown"]',
    'Fat embolism occurs 24-72 hours after long bone/pelvis fracture. Fat globules enter bloodstream, lodge in lungs/brain. Classic triad: respiratory distress, neurological changes, petechial rash on chest/axillae. Prevention: early immobilization.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '505F7C12-1654-455B-B966-CD46923DB670',
    'Which laboratory value indicates disseminated intravascular coagulation (DIC)?',
    'Decreased platelets, prolonged PT/PTT, elevated D-dimer',
    '["Increased platelets, decreased PT/PTT", "Normal clotting studies", "Elevated hemoglobin"]',
    'DIC: widespread clotting depletes clotting factors and platelets, causing bleeding. Labs: low platelets, low fibrinogen, prolonged PT/PTT, elevated D-dimer/FDP. Treatment: treat underlying cause, replace blood products.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7680E7B1-29B3-44BE-97E9-CF5CC6392B2E',
    'A patient with a pacemaker should avoid which item?',
    'MRI machines',
    '["Microwave ovens", "Television remote controls", "Electric blankets"]',
    'MRI''s strong magnetic field can damage pacemaker, cause burns, or alter settings. Modern microwaves, TVs, and most household items are safe. Patients should carry pacemaker ID card and alert medical personnel before procedures.',
    'Med-Surg',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'AE13BBE4-E8DC-4A6D-BF00-3E2C6D5C3C2D',
    'What is the FIRST action when a patient''s chest tube becomes disconnected?',
    'Submerge the tube end in sterile water or saline',
    '["Clamp the chest tube immediately", "Have patient perform Valsalva maneuver", "Remove the chest tube"]',
    'Submerging in sterile water creates water seal, preventing air entry. Clamping risks tension pneumothorax. Reconnect to drainage system ASAP. If tube falls out of patient, cover site with petroleum gauze taped on 3 sides.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B27BF6E5-B43D-4A12-B91F-92203CBEF3D8',
    'A patient receiving TPN develops fever and chills. What should the nurse suspect?',
    'Catheter-related bloodstream infection',
    '["Hypoglycemia", "Fluid overload", "Allergic reaction to lipids"]',
    'Central line infections are common with TPN. Signs: fever, chills, redness/drainage at site. Blood cultures needed (peripheral and from line). May need line removal. Prevention: strict aseptic technique, site care per protocol.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '8464BC4C-EC97-4990-90C6-D6B61AD6F7AF',
    'Which electrolyte imbalance causes tall, peaked T waves on ECG?',
    'Hyperkalemia',
    '["Hypokalemia", "Hypercalcemia", "Hyponatremia"]',
    'Hyperkalemia (K >5.0): tall peaked T waves, widened QRS, flattened P waves, can progress to V-fib/asystole. Treatment: calcium gluconate (stabilizes heart), insulin+glucose, kayexalate, dialysis. Causes: renal failure, ACE inhibitors, potassium supplements.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '219F7D22-AB7E-4752-B028-DF5525CA264F',
    'A patient with a tracheostomy has thick secretions. What intervention helps?',
    'Increase humidification and ensure adequate hydration',
    '["Decrease fluid intake", "Use heated dry oxygen", "Suction more frequently without other interventions"]',
    'Tracheostomy bypasses normal humidification of upper airway. Thick secretions indicate inadequate humidity. Increase humidification, ensure fluid intake of 2-3L/day (if not contraindicated), and instill saline before suctioning if needed.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '182F61D4-B8C3-44D4-9888-BAF734D4565F',
    'What is the normal central venous pressure (CVP) range?',
    '2-6 mmHg (or 3-8 cm H2O)',
    '["10-15 mmHg", "0-1 mmHg", "20-25 mmHg"]',
    'CVP reflects right heart preload/fluid status. Low CVP: hypovolemia. High CVP: fluid overload, right heart failure, cardiac tamponade. Measured via central line, patient flat, at end-expiration.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A19E76DC-A740-4D2E-B27D-1D0B3675BAEA',
    'A patient with peptic ulcer disease has black, tarry stools. What does this indicate?',
    'Upper GI bleeding',
    '["Lower GI bleeding", "Constipation", "Normal finding with iron supplements"]',
    'Melena (black tarry stool) indicates upper GI bleed - blood is digested as it passes through GI tract. Bright red blood per rectum (hematochezia) usually indicates lower GI bleed. Iron supplements cause dark but not tarry stools.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6638210A-D5CD-4807-A2F8-D0A07F5DF024',
    'A patient on warfarin has an INR of 5.2. What should the nurse expect?',
    'Hold warfarin and possibly administer vitamin K',
    '["Increase the warfarin dose", "Continue warfarin as ordered", "Administer heparin"]',
    'Therapeutic INR for most conditions: 2.0-3.0. INR >4 increases bleeding risk significantly. Hold warfarin, give vitamin K for high INR (oral for non-bleeding, IV for severe bleeding). Monitor for bleeding signs.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'BC046EA9-3020-4443-AB68-83C37C0D2C7C',
    'Which medication requires the patient to avoid tyramine-rich foods?',
    'MAO inhibitors (phenelzine, tranylcypromine)',
    '["SSRIs", "Benzodiazepines", "Tricyclic antidepressants"]',
    'MAOIs prevent tyramine breakdown. Tyramine causes norepinephrine release, leading to hypertensive crisis. Avoid: aged cheese, cured meats, red wine, soy sauce, sauerkraut. Crisis signs: severe headache, hypertension, stiff neck.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C8796B89-69A7-4082-82C8-77B4DE8DE7A6',
    'What is the antidote for benzodiazepine overdose?',
    'Flumazenil (Romazicon)',
    '["Naloxone", "Acetylcysteine", "Protamine sulfate"]',
    'Flumazenil competitively inhibits benzodiazepines at receptor site. Use cautiously - can precipitate seizures in chronic benzodiazepine users or those who ingested seizure-causing drugs. Short half-life may require repeated doses.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EA275E7D-D0BF-4990-9D41-E7357E3B4BC6',
    'A patient on lithium has a level of 2.1 mEq/L. What should the nurse do?',
    'Hold the medication and notify the provider immediately',
    '["Give the next scheduled dose", "Increase fluid intake only", "Wait for next scheduled level check"]',
    'Lithium therapeutic range: 0.6-1.2 mEq/L. Level >1.5 is toxic. Signs: tremors, GI upset, confusion, seizures. Hold drug, hydrate, may need dialysis. Causes: dehydration, NSAIDs, ACE inhibitors, sodium restriction.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '373544FD-FDE1-413A-BF04-050BF43D8406',
    'Which medication should be taken on an empty stomach?',
    'Levothyroxine (Synthroid)',
    '["Ibuprofen", "Metformin", "Prednisone"]',
    'Levothyroxine absorption is decreased by food, calcium, iron, antacids. Take 30-60 minutes before breakfast or at bedtime. Consistent timing important for stable levels. Monitor TSH every 6-8 weeks when adjusting dose.',
    'Pharmacology',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '16B0164C-FE48-42EF-9675-9CC1F4CD2BB2',
    'What is the PRIMARY concern when giving IV potassium?',
    'Never give IV push - can cause fatal cardiac arrhythmias',
    '["It must be given with insulin", "It causes severe hypotension", "It must be refrigerated"]',
    'IV potassium must be diluted and given slowly (usually 10 mEq/hour max via peripheral line). Rapid infusion causes cardiac arrest. Never give IV push. Infusion should be on a pump. Causes burning - may need central line for high concentrations.',
    'Pharmacology',
    'Safe & Effective Care',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C2ECE964-DA7C-4AD0-8071-87C4FB8FF161',
    'A patient taking metformin is scheduled for a CT with contrast. What should occur?',
    'Hold metformin for 48 hours after the procedure',
    '["Continue metformin as scheduled", "Take double dose after procedure", "Stop metformin permanently"]',
    'Contrast media can cause acute kidney injury. Metformin is renally excreted - combining with AKI can cause lactic acidosis. Hold 48 hours after contrast, resume after renal function confirmed normal.',
    'Pharmacology',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CB745D91-15AB-4DA0-85DB-51CCD2B6B019',
    'Which assessment is essential before giving an ACE inhibitor?',
    'Blood pressure and potassium level',
    '["Blood glucose level", "Heart rate only", "Respiratory rate"]',
    'ACE inhibitors cause hypotension (especially first dose) and hyperkalemia (reduce aldosterone). Also monitor for angioedema, dry cough, and renal function. Contraindicated in pregnancy. Examples: lisinopril, enalapril (-pril ending).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D4854CD3-367C-41E1-A281-E7D59CEE775B',
    'A patient is prescribed gentamicin. Which labs require monitoring?',
    'Peak and trough levels, BUN, and creatinine',
    '["Liver enzymes only", "Complete blood count only", "Cholesterol levels"]',
    'Aminoglycosides (gentamicin, tobramycin) are nephrotoxic and ototoxic. Monitor: peak (efficacy), trough (toxicity), renal function. Assess for hearing loss, tinnitus, vertigo. Ensure adequate hydration.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '69E2DE79-1281-4B50-97FE-FD611F287CDF',
    'What is the mechanism of action of beta-blockers?',
    'Block beta-adrenergic receptors, decreasing heart rate and blood pressure',
    '["Increase calcium influx into heart cells", "Stimulate alpha receptors", "Directly dilate blood vessels"]',
    'Beta-blockers (-olol ending) block sympathetic stimulation. Effects: decreased HR, BP, contractility, oxygen demand. Used for HTN, angina, MI, heart failure, arrhythmias. Contraindicated in asthma, severe bradycardia.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F33802EC-90BD-4B42-B757-8385A66E803F',
    'A patient on phenytoin has gingival hyperplasia. What teaching is appropriate?',
    'Maintain meticulous oral hygiene and regular dental visits',
    '["Stop taking the medication immediately", "This will resolve without intervention", "Increase the medication dose"]',
    'Gingival hyperplasia is common side effect of phenytoin. Good oral hygiene (brushing, flossing, dental visits) minimizes severity. Other side effects: hirsutism, ataxia, nystagmus. Monitor drug levels (therapeutic: 10-20 mcg/mL).',
    'Pharmacology',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '62628189-B945-46F8-AE2D-66CC09FD4493',
    'Which medication requires a filter needle for withdrawal from ampule?',
    'Any medication drawn from a glass ampule',
    '["Only insulin preparations", "Only IV antibiotics", "Only narcotic medications"]',
    'Glass particles can fall into ampule when broken. Filter needle (or straw) removes glass fragments during withdrawal. Change to regular needle before injection. This prevents injection of glass particles into patient.',
    'Pharmacology',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D4123CCB-5092-44E2-980E-29F4C9B4A3A4',
    'A patient is receiving vancomycin. What adverse effect requires immediate attention?',
    'Red man syndrome (flushing of face and trunk)',
    '["Mild nausea", "Injection site discomfort", "Drowsiness"]',
    'Red man syndrome: histamine release causing flushing, pruritus, hypotension. Caused by rapid infusion. Treatment: slow/stop infusion, antihistamines. Infuse over at least 60 minutes. Also monitor for ototoxicity, nephrotoxicity.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0FD72B24-7F2A-4F0A-868E-1E85023A362C',
    'What teaching should be provided about nitroglycerin sublingual tablets?',
    'Store in dark glass container, replace every 6 months, should cause slight burning under tongue',
    '["Chew the tablet thoroughly", "Take with a full glass of water", "Store in plastic container"]',
    'Nitroglycerin is light-sensitive and volatile. Dark container, away from heat/moisture. Slight burning/tingling indicates potency. If no relief after 3 tablets (5 min apart), call 911. Sit or lie down - causes hypotension.',
    'Pharmacology',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0C0AE1B9-9657-4633-80B8-4F67D15806F3',
    'A patient taking amlodipine reports swollen ankles. What should the nurse explain?',
    'Peripheral edema is a common side effect of calcium channel blockers',
    '["This indicates heart failure", "The medication is not working", "This is an allergic reaction"]',
    'CCBs (-dipine ending) cause vasodilation, which can lead to peripheral edema. Not related to fluid overload. Usually dose-related. Other side effects: headache, flushing, dizziness, constipation (especially verapamil).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '37E1149D-635E-43A2-A7C6-7913265A2980',
    'What is the antidote for acetaminophen overdose?',
    'Acetylcysteine (Mucomyst)',
    '["Flumazenil", "Naloxone", "Vitamin K"]',
    'Acetylcysteine replenishes glutathione, which detoxifies acetaminophen metabolites. Most effective within 8 hours but may help up to 24 hours. Overdose causes hepatotoxicity. Max daily dose: 4g/day (less in alcoholics).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '992F536B-9BE8-4FA6-8E31-DC7E26135A03',
    'A patient on corticosteroids should be monitored for which condition?',
    'Hyperglycemia and adrenal suppression',
    '["Hypoglycemia", "Excessive weight loss", "Hypotension"]',
    'Corticosteroids cause: hyperglycemia, immunosuppression, osteoporosis, adrenal suppression, weight gain, mood changes, peptic ulcers. Never stop abruptly after long-term use - taper gradually to prevent adrenal crisis.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D5168951-EE1A-4625-BEE6-8594186B915A',
    'Which statement indicates understanding of albuterol inhaler use?',
    'I should use this when I feel short of breath for quick relief',
    '["I should use this on a regular schedule twice daily", "This will reduce the inflammation in my airways", "I should take this before my steroid inhaler"]',
    'Albuterol is a short-acting beta-2 agonist (SABA) - rescue inhaler for acute symptoms. Works in minutes. If using steroid inhaler too, use albuterol first to open airways. Overuse indicates poor asthma control.',
    'Pharmacology',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4AD8E59D-066C-40F5-819E-E01A318EE788',
    'A patient on clozapine requires monitoring for which serious adverse effect?',
    'Agranulocytosis (severe drop in white blood cells)',
    '["Elevated cholesterol", "Hair loss", "Weight loss"]',
    'Clozapine can cause life-threatening agranulocytosis. Requires weekly WBC monitoring initially, then bi-weekly, then monthly. Also monitor for myocarditis, seizures, metabolic syndrome. Only dispensed through REMS program.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EE9CA70E-1B27-43EA-A847-96903FFC0949',
    'What is important teaching about taking iron supplements?',
    'Take on empty stomach with vitamin C, avoid taking with antacids or dairy',
    '["Take with milk for better absorption", "Take with antacids to prevent stomach upset", "Take with calcium supplements"]',
    'Iron absorption enhanced by vitamin C, decreased by calcium, antacids, dairy, caffeine. Take 1 hour before or 2 hours after meals. Expect dark stools. Take liquid iron through straw to prevent tooth staining.',
    'Pharmacology',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9712D72C-645A-4FFB-B07C-3AEA699B9257',
    'At what age do most children achieve bowel and bladder control?',
    '2-3 years old',
    '["6-12 months old", "4-5 years old", "6-7 years old"]',
    'Most children show readiness signs around 18-24 months. Daytime control usually achieved by age 3, nighttime control may take longer (up to age 5-6 is normal). Signs: staying dry for 2 hours, awareness of urge.',
    'Pediatrics',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '78275C4C-C267-4F49-86C7-A0E672F2E409',
    'A 2-year-old is admitted with epiglottitis. What is the PRIORITY nursing action?',
    'Keep the child calm and prepare for possible emergency airway management',
    '["Examine the throat with a tongue depressor", "Place the child flat in bed", "Obtain a throat culture immediately"]',
    'Epiglottitis is airway emergency. NEVER examine throat - can trigger complete obstruction. Keep child calm, upright (tripod position), prepare emergency airway equipment. Classic signs: drooling, dysphagia, distress, high fever.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'DEFF470F-7576-42F3-8E84-24788623120F',
    'What is the appropriate pain assessment tool for a 4-year-old?',
    'FACES pain rating scale',
    '["Numeric 0-10 scale", "Visual analog scale", "McGill Pain Questionnaire"]',
    'FACES scale uses cartoon faces from smiling to crying. Appropriate for children 3-8 years. Numeric scales appropriate around age 7-8 when child understands number concepts. Always believe child''s self-report of pain.',
    'Pediatrics',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '757CEB82-AE73-44BD-8D83-E5B4D3FAE05B',
    'A child with pyloric stenosis typically presents with what type of vomiting?',
    'Projectile, nonbilious vomiting after feeding',
    '["Bilious (green) vomiting", "Vomiting with diarrhea", "Blood-tinged vomiting"]',
    'Pyloric stenosis: thickened pylorus obstructs gastric outlet. Vomiting is projectile (forceful), nonbilious (obstruction is before bile duct entry). Occurs 2-4 weeks of age. "Olive-shaped" mass palpable. Treatment: pyloromyotomy.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '8C064F90-4089-49D8-8E88-5F9472F8B1A0',
    'What position should an infant with gastroesophageal reflux be placed after feeding?',
    'Upright or elevated prone position for 30 minutes',
    '["Flat on back immediately", "Left side-lying flat", "Trendelenburg position"]',
    'Upright position uses gravity to keep stomach contents down. Elevate HOB 30°. Feed smaller, frequent amounts. Thickened feedings may help. Burp frequently during feeding. For sleep, back position is still recommended (SIDS prevention).',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'B440B580-729B-4C04-BDB3-C5BA784556D5',
    'A child with croup has a barking cough. What intervention provides relief?',
    'Cool mist humidifier or exposure to cool night air',
    '["Hot steam inhalation", "Cough suppressants", "Chest physiotherapy"]',
    'Croup (laryngotracheobronchitis) causes barking seal-like cough, stridor, hoarseness. Cool mist reduces airway edema. Taking child outside in cool air often helps. Severe cases: racemic epinephrine, corticosteroids.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2C8DEA9D-07D5-4FD7-8B31-347B06E4E03E',
    'What is the MOST common cause of bacterial meningitis in infants?',
    'Group B Streptococcus',
    '["Haemophilus influenzae", "Staphylococcus aureus", "Pseudomonas aeruginosa"]',
    'In neonates/young infants: Group B Strep, E. coli, Listeria. In older children: S. pneumoniae, N. meningitidis. H. influenzae decreased due to vaccination. Classic signs in infants: bulging fontanel, poor feeding, irritability.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9F0D92CF-20CE-4144-8E4F-7B0F8A688285',
    'A child with sickle cell disease develops sudden severe chest pain and fever. What should the nurse suspect?',
    'Acute chest syndrome',
    '["Anxiety attack", "Costochondritis", "Muscle strain"]',
    'Acute chest syndrome is leading cause of death in sickle cell. Sickling in pulmonary vessels causes chest pain, fever, respiratory distress, new infiltrate on X-ray. Treatment: oxygen, hydration, transfusion, antibiotics, pain management.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F9A0146E-5C06-4859-9C5D-A9601E10C359',
    'At what age should a child receive the MMR vaccine?',
    '12-15 months with second dose at 4-6 years',
    '["Birth", "2 months", "6 months"]',
    'MMR given at 12-15 months (maternal antibodies wane), second dose 4-6 years. Live vaccine - contraindicated in immunocompromised, pregnancy. Side effects: fever, rash 7-10 days post-vaccination. No MMR-autism link.',
    'Pediatrics',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '17714CA7-F72A-4A72-9AFD-2FDC853DD27A',
    'What is the FIRST sign of respiratory distress in infants?',
    'Increased respiratory rate (tachypnea)',
    '["Cyanosis", "Bradycardia", "Loss of consciousness"]',
    'Tachypnea is earliest sign. Other signs: nasal flaring, retractions (substernal, intercostal, supraclavicular), grunting, head bobbing, seesaw breathing. Cyanosis is late sign. Normal infant RR: 30-60/min.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EC97225F-BDC5-43A8-929C-B9B5BDDB1DAA',
    'A child is diagnosed with Kawasaki disease. What is the MOST serious complication?',
    'Coronary artery aneurysms',
    '["Skin rash", "Lymph node swelling", "Joint pain"]',
    'Kawasaki disease causes vasculitis. Without treatment, 25% develop coronary artery aneurysms. Treatment: high-dose IVIG and aspirin within 10 days of onset reduces risk to 4%. Monitor with echocardiograms.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0E4E0B8F-97A4-4281-9A5C-745A2EBAF842',
    'What is the appropriate nursing response to breath-holding spells in a toddler?',
    'Reassure parents that spells are benign and child will resume breathing',
    '["Perform CPR immediately", "Splash cold water on the child''s face", "Shake the child vigorously"]',
    'Breath-holding spells occur in toddlers during frustration/anger. Child may turn blue, lose consciousness briefly. Self-limiting - child will breathe when CO2 rises. Stay calm, ensure safety, don''t reinforce behavior with excessive attention.',
    'Pediatrics',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '46FC4FCA-703D-4EB7-A8CB-0BE5184EAD59',
    'A child with leukemia has a platelet count of 15,000/mm³. What precaution is essential?',
    'Bleeding precautions - avoid contact sports, use soft toothbrush, no rectal temperatures',
    '["Strict isolation", "Increased physical activity", "High-fiber diet"]',
    'Thrombocytopenia (<50,000) increases bleeding risk. Precautions: soft toothbrush, electric razor, no contact sports, avoid IM injections if possible, apply pressure to puncture sites, no rectal temps. Watch for petechiae, bruising.',
    'Pediatrics',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D6348F9E-4174-47F0-ADB8-A98C98436456',
    'What is the normal blood pressure for a 6-year-old child?',
    'Approximately 95-105/55-65 mmHg',
    '["120/80 mmHg", "70/40 mmHg", "140/90 mmHg"]',
    'Pediatric BP varies by age. Rough formula: systolic = 90 + (2 × age in years). Use appropriate size cuff (bladder covers 80-100% of arm circumference). HTN defined as ≥95th percentile for age/height/sex.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '8FD3A2D0-F6CB-403B-B8B4-31A1F442202B',
    'A child with nephrotic syndrome will have which characteristic finding?',
    'Proteinuria, hypoalbuminemia, and generalized edema',
    '["Hematuria and hypertension", "Decreased urine protein", "Weight loss"]',
    'Nephrotic syndrome: massive protein loss in urine → low albumin → decreased oncotic pressure → edema (periorbital, ascites, scrotal). Hyperlipidemia also common. Treatment: corticosteroids, manage edema, prevent infection.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E3D6A744-1F55-4626-ADEC-3C4258C6C296',
    'What immunization is given at birth?',
    'Hepatitis B vaccine',
    '["MMR vaccine", "Varicella vaccine", "DTaP vaccine"]',
    'Hepatitis B is given within 24 hours of birth (especially if mother is HBsAg positive). Series completed at 1-2 months and 6-18 months. If mother is HBsAg positive, infant also receives HBIG within 12 hours.',
    'Pediatrics',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6EDEFC09-6D29-47B9-9429-8017C14FC6D2',
    'What developmental milestone should a 9-month-old infant demonstrate?',
    'Sits without support, crawls, says ''mama/dada'' nonspecifically',
    '["Walks independently", "Speaks in sentences", "Draws circles"]',
    '9-month milestones: sits well, crawls, pulls to stand, pincer grasp developing, stranger anxiety, understands ''no,'' babbles with consonant sounds. Red flags: not sitting, no babbling, doesn''t respond to name.',
    'Pediatrics',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F7543969-2778-4B8C-B75C-368DD10077C0',
    'A child is receiving IV fluids. What is the hourly maintenance rate for a 15 kg child?',
    '50 mL/hour (4-2-1 rule)',
    '["15 mL/hour", "100 mL/hour", "150 mL/hour"]',
    '4-2-1 rule: 4 mL/kg/hr for first 10 kg + 2 mL/kg/hr for next 10 kg + 1 mL/kg/hr for remaining. 15 kg = (10×4) + (5×2) = 40 + 10 = 50 mL/hour. Always verify calculations.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F6136AF3-8FC1-4EDA-87F3-65D43C140A06',
    'What is the BEST way to assess pain in a preverbal infant?',
    'Use behavioral cues: facial expression, crying, body movement (FLACC scale)',
    '["Ask the parent to rate pain 0-10", "Assume no crying means no pain", "Use numeric rating scale"]',
    'FLACC: Face, Legs, Activity, Cry, Consolability - scored 0-2 each. Total 0-10. Infants show pain through grimacing, rigid body, high-pitched cry, inconsolability. Physiologic signs (HR, BP) are less reliable.',
    'Pediatrics',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6717D3E9-785A-4BC3-A8F8-3D36EB988EA3',
    'A child with suspected intussusception will have which classic stool finding?',
    'Currant jelly stools (blood and mucus)',
    '["Clay-colored stools", "Black tarry stools", "Green watery stools"]',
    'Intussusception: bowel telescopes into itself, causing obstruction and ischemia. Classic triad: colicky abdominal pain, vomiting, currant jelly stools. Sausage-shaped mass palpable. Treatment: air/barium enema reduction or surgery.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D0916894-8111-41B2-97F9-553F207141EC',
    'During labor, what fetal heart rate pattern indicates cord compression?',
    'Variable decelerations',
    '["Early decelerations", "Late decelerations", "Accelerations"]',
    'Variable decelerations: abrupt drops in FHR with variable timing relative to contractions - caused by cord compression. Early decels (mirror contractions) = head compression (benign). Late decels = uteroplacental insufficiency (concerning).',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0EAEB539-A150-4531-9838-547A323F230C',
    'What is the PRIORITY nursing action for late decelerations?',
    'Turn mother to left side, increase IV fluids, administer oxygen, stop Pitocin if running',
    '["Prepare for immediate cesarean", "Continue monitoring only", "Increase Pitocin rate"]',
    'Late decels indicate fetal hypoxia from uteroplacental insufficiency. Intrauterine resuscitation: position change (left lateral), O2 by mask, increase fluids, stop oxytocin, notify provider. If pattern persists, prepare for delivery.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E86E9810-1278-4F31-A8F4-4744B1FD4611',
    'A woman at 32 weeks gestation reports sudden gush of fluid from vagina. What is the FIRST action?',
    'Assess for umbilical cord prolapse',
    '["Perform vaginal exam to check dilation", "Start Pitocin to induce labor", "Discharge home with instructions"]',
    'Premature rupture of membranes (PROM) risk: cord prolapse, infection. Assess for cord at introitus or in vagina. If cord visible, elevate presenting part, position knee-chest, prepare for emergency cesarean. Use sterile speculum (not digital) exam.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2099678C-9EC3-40E1-8C9F-7134583FDB4D',
    'What is the normal fetal heart rate baseline?',
    '110-160 beats per minute',
    '["80-100 beats per minute", "60-80 beats per minute", "160-200 beats per minute"]',
    'Normal FHR: 110-160 bpm. Tachycardia >160 (maternal fever, fetal hypoxia, infection). Bradycardia <110 (cord compression, congenital heart block, prolonged hypoxia). Moderate variability is reassuring (6-25 bpm fluctuation).',
    'Maternity',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2171A8BC-361C-4B56-8A42-CDB243AD3B70',
    'A pregnant woman has a positive glucose challenge test. What is the next step?',
    '3-hour glucose tolerance test',
    '["Start insulin immediately", "Repeat 1-hour test in one week", "No further testing needed"]',
    '1-hour GCT is screening (50g glucose, abnormal if ≥140). If positive, confirm with 3-hour GTT (100g glucose, fasting then 1, 2, 3 hours). GDM diagnosed if 2+ values abnormal. Manage with diet first, then insulin if needed.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3821C935-EF6D-490D-AA3E-89A2672A202B',
    'What medication is given to prevent neonatal Group B Strep infection during labor?',
    'Intravenous penicillin or ampicillin',
    '["Oral erythromycin", "Intramuscular ceftriaxone", "Topical antibiotics"]',
    'GBS prophylaxis: IV penicillin G or ampicillin during labor, starting at least 4 hours before delivery. Given to GBS+ mothers or those with risk factors (preterm, prolonged ROM, fever). Prevents early-onset neonatal GBS sepsis.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '53A368CE-793D-4CF2-B614-702F8FF1A117',
    'A woman 2 hours postpartum has a boggy uterus and heavy bleeding. What is the FIRST action?',
    'Massage the uterine fundus',
    '["Administer pain medication", "Insert Foley catheter", "Prepare for surgery"]',
    'Boggy uterus = uterine atony, #1 cause of postpartum hemorrhage. First intervention: fundal massage to stimulate contraction. Keep bladder empty (full bladder displaces uterus). Oxytocin, methylergonovine, or prostaglandins if massage ineffective.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6DA3EA7F-4A67-4340-8FEB-000C8CFBEC8E',
    'What is the expected fundal height at 20 weeks gestation?',
    'At the level of the umbilicus',
    '["At the symphysis pubis", "Halfway between umbilicus and xiphoid", "At the xiphoid process"]',
    'Fundal height in cm ≈ weeks gestation (16-36 weeks). At 12 weeks: at symphysis pubis. At 20 weeks: at umbilicus. At 36 weeks: at xiphoid. After 36 weeks may decrease as baby drops. Discrepancy >3 cm warrants evaluation.',
    'Maternity',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E680F5F8-D857-472F-8749-CB371B7EA067',
    'A laboring woman requests an epidural. What must occur before administration?',
    'IV fluid bolus (500-1000 mL) and verify platelet count is adequate',
    '["Complete cervical dilation", "Rupture of membranes", "Administration of Pitocin"]',
    'Pre-epidural: IV access, fluid bolus (prevents hypotension from sympathetic block), normal coagulation (platelets >100,000), baseline vitals. No specific dilation required. Contraindicated: coagulopathy, infection at site, increased ICP.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'AB18C7B0-BCE5-4379-9029-FD7C11015E60',
    'What is Naegele''s rule for calculating estimated due date?',
    'First day of LMP minus 3 months plus 7 days plus 1 year',
    '["First day of LMP plus 9 months", "Last day of LMP plus 280 days", "First day of LMP plus 40 days"]',
    'Naegele''s rule: LMP + 7 days - 3 months + 1 year. Example: LMP January 1 → EDD October 8. Assumes 28-day cycle with ovulation day 14. Ultrasound dating most accurate in first trimester.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '382EE310-D006-4E01-AEDC-DDC7092E3A3C',
    'A pregnant woman at 34 weeks has severe headache, visual changes, and BP 168/110. What condition is suspected?',
    'Severe preeclampsia',
    '["Migraine headache", "Normal pregnancy discomfort", "Gestational hypertension"]',
    'Preeclampsia: HTN + proteinuria after 20 weeks. Severe features: BP ≥160/110, headache, visual changes, RUQ pain, elevated liver enzymes, low platelets, renal dysfunction. Treatment: magnesium sulfate (seizure prevention), antihypertensives, delivery.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C4F37C66-026F-4D02-B029-2F4C6FF0421E',
    'What is the antidote for magnesium sulfate toxicity?',
    'Calcium gluconate',
    '["Protamine sulfate", "Vitamin K", "Naloxone"]',
    'Magnesium toxicity signs (in order): loss of DTRs, respiratory depression, cardiac arrest. Monitor: DTRs (should be present), respirations (>12/min), urine output (>30 mL/hr). Therapeutic level: 4-7 mEq/L. Keep calcium gluconate at bedside.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E94DA8E6-D72C-4F49-A6EE-9F9F607F75D1',
    'What is the purpose of giving Rh immune globulin (RhoGAM)?',
    'To prevent Rh sensitization in Rh-negative mothers exposed to Rh-positive blood',
    '["To treat Rh disease in the newborn", "To prevent GBS infection", "To stimulate fetal lung maturity"]',
    'RhoGAM prevents maternal antibody formation against Rh+ fetal cells. Given at 28 weeks and within 72 hours of delivery (if baby Rh+), and after any bleeding event, amniocentesis, or pregnancy loss. Not needed if father confirmed Rh-negative.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '309BB605-E872-4111-8B6C-E7A3C3D41E66',
    'A woman is in the second stage of labor. What characterizes this stage?',
    'Complete cervical dilation (10 cm) until delivery of the baby',
    '["Onset of contractions until complete dilation", "Delivery of baby until delivery of placenta", "From admission until active labor"]',
    'Stage 1: early, active, transition - until 10 cm dilated. Stage 2: 10 cm to delivery (pushing stage). Stage 3: delivery to placenta expulsion. Stage 4: first 1-2 hours postpartum (recovery).',
    'Maternity',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CD7444E3-37A3-48D4-AD21-C7FE72740DCB',
    'What assessment finding indicates placental abruption?',
    'Painful, rigid abdomen with dark red vaginal bleeding',
    '["Painless bright red bleeding", "Soft, nontender abdomen", "Gradual onset of mild cramping"]',
    'Abruption: premature separation of placenta. Classic: painful contractions, rigid board-like abdomen, dark blood (may be concealed). Vs placenta previa: painless bright red bleeding. Both emergencies - continuous monitoring, prepare for delivery.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D479A84A-303E-4A58-8906-16D4F769FCA3',
    'How soon after delivery should breastfeeding be initiated?',
    'Within the first hour (golden hour)',
    '["After 24 hours", "Only after milk comes in", "After infant has first bath"]',
    'Early initiation (within 1 hour) promotes bonding, stimulates milk production, provides colostrum (rich in antibodies). Skin-to-skin contact helps regulate infant temperature and promotes rooting/latching. Delay bath until after first feed.',
    'Maternity',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0F422F78-A6B8-4EC5-A1FA-0EA70198C1D2',
    'A newborn has a 1-minute Apgar score of 4. What is the PRIORITY action?',
    'Provide positive pressure ventilation and stimulation',
    '["Perform chest compressions immediately", "Give IV epinephrine", "Place under warmer and observe"]',
    'Apgar 4-6: moderately depressed. Steps: warm, dry, stimulate, suction if needed, provide oxygen/PPV. Chest compressions if HR <60 after 30 seconds of effective ventilation. Apgar reassessed at 5 minutes. Scores 7-10 normal.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '787C974E-07EC-42F9-8B6C-A2B34D7F18BE',
    'When does lochia normally change from rubra to serosa?',
    'Around days 4-10 postpartum',
    '["Within 24 hours", "After 2 weeks", "After 6 weeks"]',
    'Lochia rubra: days 1-3, bright red. Serosa: days 4-10, pinkish-brown. Alba: days 11-21+, yellowish-white. Return to rubra or foul odor suggests infection. Heavy bleeding with clots after first few hours is abnormal.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CB4E2561-55F9-4E99-93AA-34C885124877',
    'A pregnant woman should avoid which food due to listeria risk?',
    'Unpasteurized soft cheeses and deli meats',
    '["Cooked chicken", "Pasteurized milk", "Well-done hamburgers"]',
    'Listeriosis in pregnancy can cause miscarriage, stillbirth, preterm labor. Avoid: unpasteurized dairy, soft cheeses (brie, feta, queso fresco), deli meats (unless heated steaming hot), hot dogs, refrigerated smoked seafood.',
    'Maternity',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '641905F5-194C-4BE2-A271-73AD43516558',
    'What fetal position is ideal for vaginal delivery?',
    'Occiput anterior (OA)',
    '["Occiput posterior (OP)", "Breech", "Transverse lie"]',
    'OA: fetal occiput toward mother''s front - smallest diameter presents, smoothest delivery. OP (sunny-side up): causes back labor, longer pushing. Breech: feet/buttocks first - usually cesarean. Transverse: shoulder presentation - cesarean required.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A0C6689E-5349-4506-96E2-0F672D26CA72',
    'A patient with bipolar disorder in manic phase is talking rapidly and hasn''t slept in 3 days. What is the PRIORITY?',
    'Ensure safety and provide a calm, low-stimulation environment',
    '["Encourage group activities", "Provide detailed explanations", "Confront the behavior"]',
    'Manic patients: flight of ideas, decreased sleep, impulsivity, poor judgment. Priority is safety (may harm self through reckless behavior). Low stimulation, brief simple communication, nutrition/hydration, set limits calmly.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6DC98D11-2A56-4E91-9D87-DBB0A3B2FCCE',
    'Which statement indicates a patient may be at HIGH risk for suicide?',
    'I''ve given away my favorite things and written letters to my family',
    '["I sometimes feel sad", "I wish things were different", "I get frustrated easily"]',
    'Giving away possessions, making final arrangements, sudden calmness after depression, having specific plan with means = HIGH risk. Always take seriously, ask directly about suicide, ensure safety, remove means, constant observation.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '59182B48-7262-459C-8F13-EBD29F88E93B',
    'A patient with schizophrenia believes the TV is sending special messages to them. This is an example of:',
    'Delusion of reference',
    '["Hallucination", "Delusion of grandeur", "Delusion of persecution"]',
    'Delusions of reference: belief that random events have personal significance. Grandeur: inflated self-importance. Persecution: belief others are plotting against them. Hallucinations are sensory experiences (hearing/seeing things not there).',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '84C0FDAB-1D35-47BD-94DD-E1C1020CE543',
    'What is the therapeutic lithium level for maintenance?',
    '0.6-1.2 mEq/L',
    '["2.0-3.0 mEq/L", "0.1-0.3 mEq/L", "3.0-4.0 mEq/L"]',
    'Therapeutic: 0.6-1.2 mEq/L. Toxic >1.5 mEq/L. Narrow therapeutic index. Monitor levels regularly. Toxicity signs: GI upset, tremors, confusion, seizures. Maintain sodium/fluid intake, avoid NSAIDs which increase levels.',
    'Mental Health',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '89B974CF-5FE0-4AC0-87E2-CA47D40E7CA6',
    'A patient taking haloperidol develops fever, muscle rigidity, and altered consciousness. What is suspected?',
    'Neuroleptic malignant syndrome (NMS)',
    '["Extrapyramidal symptoms", "Tardive dyskinesia", "Akathisia"]',
    'NMS: life-threatening reaction to antipsychotics. Classic tetrad: hyperthermia, muscle rigidity (lead-pipe), altered mental status, autonomic instability. Stop medication immediately, supportive care, dantrolene/bromocriptine. Mortality 10-20%.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '249DB344-7EA5-4355-8C56-F396C9055D8B',
    'What is the MOST effective therapy for panic disorder?',
    'Cognitive behavioral therapy combined with medication',
    '["Psychoanalysis alone", "Medication alone long-term", "Group therapy only"]',
    'CBT addresses catastrophic thinking and avoidance behaviors. SSRIs are first-line medication. Benzodiazepines for acute attacks only (short-term due to dependence). Combination therapy most effective for long-term management.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'F6854E9D-BEC8-4E0D-9110-744B7DC3F700',
    'A patient with anorexia nervosa refuses to eat. What is the PRIORITY concern?',
    'Electrolyte imbalances and cardiac arrhythmias',
    '["Body image disturbance", "Family dynamics", "Self-esteem issues"]',
    'Anorexia has highest mortality of psychiatric disorders. Life-threatening: hypokalemia causes arrhythmias, hypoglycemia, dehydration, organ failure. Medical stabilization first, then address psychological issues. Monitor refeeding syndrome.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E73702F6-612F-4456-B083-8F81EFEB3163',
    'A patient with PTSD experiences flashbacks. What nursing intervention is MOST appropriate?',
    'Help ground the patient to present reality using sensory techniques',
    '["Ask detailed questions about the trauma", "Leave them alone until it passes", "Restrain the patient for safety"]',
    'Grounding techniques: name 5 things you see, 4 you hear, 3 you feel. Speak calmly, orient to present, ensure safety. Avoid retraumatizing by forcing details. Establish trust. Refer to trauma-focused therapy (EMDR, CPT).',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9D3ECA2E-C0CA-4C39-8676-F9D55423EB4C',
    'What is the FIRST-line medication class for generalized anxiety disorder?',
    'SSRIs (selective serotonin reuptake inhibitors)',
    '["Benzodiazepines", "Barbiturates", "Typical antipsychotics"]',
    'SSRIs (sertraline, escitalopram) are first-line for GAD - effective, fewer side effects, no dependence. Benzodiazepines for short-term use only due to dependence. Buspirone is non-addictive alternative. Takes 2-4 weeks for full effect.',
    'Mental Health',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '124A7469-7771-4655-9D5E-42FE6666F9B5',
    'A patient newly admitted to psychiatric unit is pacing and clenching fists. What is the PRIORITY?',
    'Approach calmly, maintain safe distance, and use de-escalation techniques',
    '["Apply restraints immediately", "Ignore the behavior", "Gather multiple staff to confront patient"]',
    'Agitation can escalate to violence. De-escalation: calm voice, open body language, safe distance, acknowledge feelings, offer choices, remove audience. Physical intervention last resort. PRN medications may help.',
    'Mental Health',
    'Safe & Effective Care',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CF18F820-74E3-4463-BB51-C7952AB28667',
    'A patient taking an SSRI wants to stop the medication abruptly. What should the nurse teach?',
    'Stopping suddenly can cause discontinuation syndrome - taper under provider guidance',
    '["It''s safe to stop any time", "Double the dose first then stop", "Switch to a benzodiazepine first"]',
    'SSRI discontinuation syndrome: flu-like symptoms, dizziness, sensory disturbances (brain zaps), anxiety, insomnia. Gradual taper over weeks prevents symptoms. More common with short half-life SSRIs (paroxetine).',
    'Mental Health',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '63BE00B8-EFA4-4CC3-B134-7E83B80A604D',
    'What is the PRIMARY characteristic of borderline personality disorder?',
    'Unstable relationships, self-image, and emotions with fear of abandonment',
    '["Persistent suspicion of others", "Lack of empathy and disregard for others", "Social withdrawal and restricted emotions"]',
    'BPD: pattern of unstable relationships, identity, emotions. Intense fear of abandonment, splitting (idealizing then devaluing), impulsivity, self-harm. Treatment: dialectical behavior therapy (DBT), no specific medication for BPD itself.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'FCF378E9-EE6E-46A9-8A9C-609C3C0BECA2',
    'A patient with OCD washes hands for hours daily. What initial approach is appropriate?',
    'Allow reasonable time for rituals while building therapeutic relationship',
    '["Prevent all hand washing immediately", "Ignore the behavior completely", "Ridicule the behavior to show it''s irrational"]',
    'OCD rituals reduce anxiety; sudden prevention increases anxiety dramatically. Build trust first. ERP (exposure response prevention) therapy gradually reduces rituals. SSRIs help. Never ridicule - patient knows behavior is irrational but can''t stop.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6FB05E70-3047-4966-B78E-443FAF0221BA',
    'What is the difference between auditory hallucinations in schizophrenia vs delirium?',
    'Schizophrenia: voices are often commanding/conversing; Delirium: usually simple sounds with visual hallucinations',
    '["There is no difference", "Delirium hallucinations are more complex", "Schizophrenia only has visual hallucinations"]',
    'Schizophrenia: auditory hallucinations predominate, often voices discussing patient or giving commands, clear consciousness. Delirium: visual hallucinations more common, fluctuating consciousness, acute onset, reversible cause.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D5DFFA74-D09A-4E3C-9949-233D5F844F57',
    'A patient is in alcohol withdrawal. What is the most serious complication to monitor for?',
    'Delirium tremens with seizures',
    '["Mild hand tremors", "Insomnia", "Loss of appetite"]',
    'DTs occur 48-72 hours after last drink. Signs: severe agitation, hallucinations, tremors, fever, tachycardia, seizures. Can be fatal. Treatment: benzodiazepines (CIWA protocol), supportive care, thiamine. Monitor Q1-2H initially.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '634E3176-E2B3-4498-B02D-C5C98F2EFA0D',
    'What nursing intervention is essential when a patient is placed in seclusion?',
    'Check patient every 15 minutes, offer food/fluids, assess for removal criteria',
    '["Check every 4 hours", "Remove all monitoring", "Keep in seclusion until morning"]',
    'Seclusion is restrictive - used only when less restrictive measures fail. Continuous observation or Q15 min checks. Regular assessment of physical/psychological status. Document behavior and rationale. Remove as soon as safe.',
    'Mental Health',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '74CD21CE-4973-4AC9-A5AD-C017D0C27E20',
    'A patient states ''The world would be better without me.'' What is the BEST response?',
    'Are you thinking about suicide?',
    '["Don''t say that!", "Tell me about your hobbies", "That''s not true, people care about you"]',
    'Ask directly and nonjudgmentally about suicide. Asking does NOT plant the idea. Assess plan, means, intent, timeline. Take all statements seriously. Ensure safety, remove means, one-to-one observation, notify provider.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5AE30383-594C-4130-9BC1-6727F7E25DA5',
    'What symptom distinguishes serotonin syndrome from NMS?',
    'Serotonin syndrome has hyperreflexia and clonus; NMS has muscle rigidity with normal/decreased reflexes',
    '["They are identical", "NMS has hyperreflexia", "Serotonin syndrome causes hypothermia"]',
    'Both: hyperthermia, altered mental status. Serotonin syndrome: clonus, hyperreflexia, diarrhea, rapid onset. NMS: lead-pipe rigidity, normal/low reflexes, slower onset. Serotonin syndrome from serotonergic drugs, NMS from antipsychotics.',
    'Mental Health',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '050C34F1-3D73-41BD-98A2-97565A94E9E4',
    'A patient with depression has been on an SSRI for 3 days and reports no improvement. What should the nurse explain?',
    'Antidepressants typically take 2-4 weeks to show full therapeutic effect',
    '["The medication isn''t working", "Dose should be doubled immediately", "Add another antidepressant now"]',
    'SSRIs take 2-4 weeks (some up to 6-8 weeks) for full effect. Early side effects often improve. Monitor for increased suicidal ideation initially (especially in youth). Continue medication as prescribed; premature stopping common.',
    'Mental Health',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9345061B-4BB3-423E-8470-B8EC4FD82D7B',
    'What is the therapeutic relationship boundary being crossed if a nurse shares personal problems with a patient?',
    'Self-disclosure that shifts focus to nurse''s needs',
    '["Appropriate empathy building", "Professional rapport development", "Required information sharing"]',
    'Therapeutic relationship is patient-focused. Limited self-disclosure may be appropriate if it benefits patient. Sharing personal problems shifts focus inappropriately, burdens patient, blurs boundaries. Maintain professional boundaries.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EB06ED5C-423C-4730-A803-B2D5ED1DD2D7',
    'Which task can the RN delegate to unlicensed assistive personnel (UAP)?',
    'Taking vital signs on a stable patient',
    '["Initial patient assessment", "Patient teaching about new medications", "Interpreting ECG rhythms"]',
    'Delegation uses the 5 Rights: Right task, circumstance, person, direction, supervision. UAPs can do routine tasks on stable patients: vitals, hygiene, feeding, ambulation. RN retains: assessment, teaching, evaluation, unstable patients.',
    'Leadership',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '857EDA2E-9389-437E-84C5-A6FA7B08157B',
    'An RN receives report on 4 patients. Which should be assessed FIRST?',
    'Patient with acute chest pain and diaphoresis',
    '["Patient requesting pain medication", "Patient due for scheduled insulin", "Patient awaiting discharge teaching"]',
    'Prioritize using ABCs and Maslow: actual/potential life threats first. Chest pain with diaphoresis = possible MI - immediate threat. Others are important but not immediately life-threatening. Assess, then notify provider.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '19C3DEE0-936D-424F-814B-9DFBA7E718FF',
    'A nurse witnesses another nurse taking controlled substances. What is the FIRST action?',
    'Report to nurse manager or supervisor immediately',
    '["Confront the nurse directly", "Ignore it to avoid conflict", "Tell coworkers about it"]',
    'Diversion is serious - patient safety and legal issue. Report to supervisor per facility policy. Don''t confront alone or gossip. Documentation of observations important. Most states have peer assistance programs vs punitive action.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'EADDE184-8D06-4223-A90B-CB94E72AFA2D',
    'What is the PRIMARY purpose of incident/occurrence reports?',
    'To identify patterns and improve quality/safety',
    '["To punish staff members", "To be used in malpractice lawsuits", "To document in the patient''s medical record"]',
    'Incident reports are internal QI documents, not part of medical record. Purpose: identify trends, prevent recurrence, improve systems. Not punitive. Do document facts of incident in medical record, but don''t reference the incident report.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '6114D6A5-18A3-4E30-AB7B-3A6FCBD7B821',
    'A patient refuses a blood transfusion due to religious beliefs. What should the nurse do?',
    'Respect the decision, document it, and inform the provider',
    '["Try to convince the patient", "Administer anyway if life-threatening", "Ignore religious concerns"]',
    'Competent adults have right to refuse treatment, even life-saving. Ensure informed decision (understanding of consequences). Document thoroughly. Explore alternatives. Court order may be sought for minors or incompetent adults.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '3081AB1F-B457-4A6F-87DB-F9DFB954DBF3',
    'Which patient can be safely assigned to an LPN/LVN?',
    'Stable patient with chronic conditions requiring routine care',
    '["Patient with acute MI", "Newly admitted patient requiring full assessment", "Patient receiving IV push medications"]',
    'LPN/LVN scope: stable patients, predictable outcomes, routine procedures, data collection (not initial assessment in most states). RN needed for: complex assessment, IV push meds, patient teaching, care planning, unstable patients.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7505CA17-B688-4632-814C-35E555E5AB35',
    'A nurse makes a medication error. What is the FIRST action?',
    'Assess the patient for adverse effects',
    '["Complete incident report immediately", "Notify the family", "Wait to see if symptoms develop"]',
    'Patient safety first - assess for harm. Then: notify provider, implement orders, document in chart, complete incident report, notify supervisor. Be honest with patient. Don''t try to cover up. Follow facility policy.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E7F774BC-C9BC-4DCE-8AF9-037D651EC6C8',
    'What does SBAR communication stand for?',
    'Situation, Background, Assessment, Recommendation',
    '["Signs, Blood pressure, Action, Response", "Symptoms, Behavior, Analysis, Report", "Status, Background, Analysis, Result"]',
    'SBAR standardizes handoff communication. Situation: what''s happening now. Background: relevant history. Assessment: what you think is the problem. Recommendation: what you think should be done. Reduces communication errors.',
    'Leadership',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '69076EC8-F534-4964-9054-37664B3B8393',
    'In a disaster/mass casualty situation, which patient receives care LAST (triage)?',
    'Patient with severe head injury, fixed dilated pupils, and agonal breathing',
    '["Patient with fractured femur", "Patient with moderate bleeding laceration", "Patient with anxiety attack"]',
    'Mass casualty triage: save the most lives with limited resources. Black tag (expectant/deceased): injuries incompatible with survival. Red: immediate threat to life. Yellow: serious but can wait. Green: minor injuries. This patient is expectant.',
    'Leadership',
    'Safe & Effective Care',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'CDB5C4BC-A02F-401F-8247-565DA769253D',
    'What is the nurse''s legal responsibility regarding informed consent?',
    'Witness the patient''s signature and ensure they had opportunity to ask questions',
    '["Explain all risks and benefits of the procedure", "Obtain consent from family members", "Determine if procedure is necessary"]',
    'Provider is responsible for explaining procedure, risks, benefits, alternatives. Nurse witnesses signature, ensures patient had questions answered, verifies identity. Nurse can reinforce teaching and assess understanding.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D600284D-200F-4301-9B07-17486044FB90',
    'A patient''s family member requests all medical information. What should the nurse do?',
    'Verify patient''s authorization or healthcare proxy status before sharing',
    '["Share all information since they are family", "Refuse any information completely", "Only share positive information"]',
    'HIPAA protects patient privacy. Only share with patient''s written authorization or legal healthcare proxy. Verify identity. Patient determines who receives information. In emergencies, limited disclosure may be appropriate.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0E96DCF9-A38E-4C31-8D3E-EC1393616142',
    'Which situation demonstrates appropriate advocacy?',
    'Questioning a medication order that seems inappropriate for the patient''s condition',
    '["Following all orders without question", "Only advocating for compliant patients", "Agreeing with the family against medical advice"]',
    'Patient advocacy: protecting patient rights and safety. Question orders that seem wrong, speak up about safety concerns, ensure informed consent, support patient decisions even if different from your own. Always act in patient''s best interest.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A822582F-DE13-4814-BB44-552EA660C495',
    'A nurse is floated to an unfamiliar unit. What is the appropriate action?',
    'Accept the assignment but request orientation and assignments within competency',
    '["Refuse to go under any circumstances", "Accept any assignment without question", "Call in sick to avoid the situation"]',
    'Nurses can be floated but should work within competency. Request orientation, ask for experienced staff as resource, accept appropriate assignments, speak up about training needs. Document concerns. Don''t abandon patients.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '09D383D1-F9E0-42D9-B7DE-997FDB307478',
    'What is the MOST effective method to prevent healthcare-associated infections?',
    'Hand hygiene before and after patient contact',
    '["Prophylactic antibiotics for all patients", "Keeping patients in isolation", "Environmental cleaning only"]',
    'Hand hygiene is #1 prevention method. WHO 5 moments: before patient contact, before aseptic tasks, after body fluid exposure, after patient contact, after touching patient surroundings. Use soap/water or alcohol-based rub.',
    'Infection Control',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '471BC0EC-9FA3-4962-AEEB-2658E00DE888',
    'A patient is on airborne precautions. What PPE is required to enter the room?',
    'N95 respirator (must be fit-tested)',
    '["Standard surgical mask", "Face shield only", "Gloves only"]',
    'Airborne precautions (TB, measles, varicella, COVID-19): N95 or higher respirator, negative pressure room, door closed. Fit-testing required. Patient wears surgical mask during transport. Droplet precautions use surgical mask.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A741A955-DB50-46E7-B5E6-459C61D1A777',
    'What is the proper sequence for donning PPE?',
    'Gown, mask/respirator, goggles/face shield, gloves',
    '["Gloves, gown, mask, goggles", "Mask, gloves, gown, goggles", "Any order is acceptable"]',
    'Donning order: hand hygiene, gown (ties in back), mask/N95, eye protection, gloves (over gown cuffs). Doffing: gloves, hand hygiene, goggles, gown, hand hygiene, mask, hand hygiene. Sequence prevents contamination.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'BABCD13D-363F-4723-AA2F-E805369BF5A3',
    'A patient with a latex allergy is scheduled for surgery. What precaution is essential?',
    'Schedule as first case of the day and ensure latex-free equipment',
    '["No special precautions needed", "Extra latex gloves available", "Pre-medicate with antibiotics"]',
    'Latex allergy can cause anaphylaxis. First case avoids latex particles in air from prior surgeries. Use latex-free gloves, catheters, supplies. Also avoid cross-reactive foods (bananas, avocados, kiwis, chestnuts).',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1ADA0D89-DEAA-4F61-B774-7767A71878D9',
    'What is the CORRECT angle for intramuscular injection in an adult?',
    '90-degree angle',
    '["15-degree angle", "45-degree angle", "5-degree angle"]',
    'IM: 90° angle into muscle. Subcutaneous: 45-90° depending on tissue. Intradermal: 5-15° almost parallel to skin. For IM, use appropriate needle length based on site and patient size. Aspirate not routinely recommended.',
    'Fundamentals',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2AB08978-AF3E-46C1-9B64-E3E699A421C9',
    'A patient has a nasogastric tube for decompression. What finding indicates proper placement?',
    'pH of aspirate is 5 or less and X-ray confirmation',
    '["Auscultation of air bolus only", "Patient can speak normally", "Tube marking at 50 cm at nares"]',
    'X-ray is gold standard for initial placement. pH <5 indicates gastric contents. Auscultation alone is unreliable. Check placement before each use. Feeding tubes require X-ray before initial feeding.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '95B55F18-8915-402E-A608-944E1696982F',
    'A patient receiving enteral feeding has residual volume of 450 mL. What should the nurse do?',
    'Hold feeding and notify the provider per facility protocol',
    '["Continue feeding as scheduled", "Discard residual and restart feeding", "Increase feeding rate"]',
    'High residual (usually >250-500 mL per protocol) indicates delayed gastric emptying - aspiration risk. Hold feeding, notify provider, assess for distension/nausea. May need prokinetic agent. Replace residual to avoid electrolyte loss.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '94F794EB-390B-48F8-949D-E4E8E3EE3529',
    'What is the appropriate nursing action when discontinuing a peripheral IV?',
    'Apply pressure for 2-3 minutes after removal, then apply bandage',
    '["Apply pressure while removing the catheter", "Leave site open to air", "Apply tourniquet above the site"]',
    'Remove catheter at angle of insertion while applying gauze above site. Apply firm pressure for 2-3 minutes (longer if anticoagulated). Check catheter tip is intact. Document removal and site condition.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5E8BDB1D-FBAF-4BD7-B195-6006DFCA4065',
    'A patient''s oxygen saturation is 88% on room air. What is the FIRST action?',
    'Apply oxygen via nasal cannula and reassess',
    '["Call a rapid response immediately", "Wait and recheck in 30 minutes", "Document the finding only"]',
    'SpO2 <90% requires intervention. Start O2, reassess, determine cause. For COPD patients, target 88-92%. If not improving or declining, escalate care. Also assess respiratory rate, work of breathing, LOC.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '637DE2AA-5817-4084-9688-4BCCAD790E64',
    'What is the preferred site for IM injection in infants?',
    'Vastus lateralis (thigh)',
    '["Dorsogluteal", "Deltoid", "Ventrogluteal"]',
    'Vastus lateralis preferred for infants/children <12 months - most developed muscle. Dorsogluteal avoided until walking well established (underdeveloped, sciatic nerve risk). Deltoid for older children/adults if small volume.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '81421848-E370-49F2-8AD1-A15325D54484',
    'A patient needs to be repositioned but is too heavy for one nurse. What should be done?',
    'Get assistance from another staff member and use proper lift equipment',
    '["Try alone using good body mechanics", "Leave patient in current position", "Ask family to help lift"]',
    'Safe patient handling prevents nurse injury (leading cause of disability). Use lift equipment, slide sheets, get help. ANA recommends mechanical lifts. Know facility policy and patient''s lift status. Don''t rely on manual lifting alone.',
    'Safety',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '82D85ABE-AFD4-4A13-A956-0A8B291FAAB7',
    'What is the proper order for physical assessment?',
    'Inspection, palpation, percussion, auscultation (except abdomen: auscultate before palpation)',
    '["Palpation, percussion, inspection, auscultation", "Auscultation first for all systems", "Any order is acceptable"]',
    'Standard sequence: inspection (look), palpation (feel), percussion (tap), auscultation (listen). Abdomen exception: auscultate before palpation/percussion to avoid altering bowel sounds.',
    'Fundamentals',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '167A3FB1-4B5C-4DDF-894F-EF813127A4DA',
    'A fire alarm sounds on your unit. What is the FIRST action?',
    'Rescue patients in immediate danger (RACE: Rescue, Alarm, Contain, Extinguish)',
    '["Locate fire extinguisher first", "Open all windows", "Continue current tasks"]',
    'RACE: Rescue (remove from danger), Alarm (pull alarm, call 911), Contain (close doors), Extinguish (or evacuate). PASS for extinguisher: Pull pin, Aim at base, Squeeze handle, Sweep side to side.',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2329B468-19CB-4F56-AC7F-E4DB8CDEE8A7',
    'A patient is prescribed enoxaparin (Lovenox) subcutaneously. Where should it be administered?',
    'Abdomen, at least 2 inches from umbilicus',
    '["Upper arm deltoid area", "Anterior thigh", "Dorsogluteal muscle"]',
    'Low molecular weight heparin (enoxaparin) given in abdominal fat, rotating sites, 2 inches from umbilicus. Do NOT aspirate or rub. Leave air bubble in syringe. Don''t expel before injecting.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '4FA81CA0-7284-44BF-BE65-4E612ADF34FD',
    'What is the normal range for blood urea nitrogen (BUN)?',
    '10-20 mg/dL',
    '["50-100 mg/dL", "0.6-1.2 mg/dL", "100-200 mg/dL"]',
    'BUN: 10-20 mg/dL. Elevated in dehydration, high protein intake, GI bleed, renal failure. Creatinine (0.6-1.2) is more specific for kidney function. BUN:creatinine ratio helps differentiate causes.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7EECB69A-B0F4-4BE8-AA80-6F4FDE4B5492',
    'A patient has a wound with serous drainage. What does this indicate?',
    'Normal clear, watery drainage from plasma',
    '["Infection requiring antibiotics", "Hemorrhage from wound", "Necrotic tissue in wound"]',
    'Serous: clear, watery, normal early healing. Sanguineous: bloody (early post-op). Serosanguineous: pink, mixed. Purulent: thick, yellow/green, indicates infection. Document amount, color, odor, wound appearance.',
    'Fundamentals',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'D7E7A0AD-6218-4942-923B-320B567AF559',
    'What nursing intervention helps prevent deep vein thrombosis in a bedridden patient?',
    'Sequential compression devices and early mobilization when possible',
    '["Strict bedrest with leg elevation", "Apply warm compresses to legs", "Restrict fluid intake"]',
    'DVT prevention: SCDs (mechanical compression), anticoagulation if ordered, early ambulation, leg exercises, adequate hydration, avoid leg crossing. Risk factors: immobility, surgery, cancer, pregnancy, clotting disorders.',
    'Fundamentals',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '0E2EDC89-5026-4345-9666-1032C76C4E21',
    'A patient refuses morning medications. What should the nurse do?',
    'Document refusal, assess reason, educate on importance, and notify provider',
    '["Force patient to take medications", "Hide medications in food", "Skip documentation"]',
    'Patients have right to refuse. Assess understanding and reason (side effects, beliefs, cost). Educate on consequences. Document refusal, reason if given, education provided. Notify provider. Don''t coerce or trick patient.',
    'Fundamentals',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '310FBD4E-7F7D-40FC-8AB2-E35E953DF1CA',
    'What is the BEST indicator of adequate fluid resuscitation?',
    'Urine output of at least 30 mL/hour (0.5 mL/kg/hour)',
    '["Normal blood pressure only", "Absence of thirst", "Moist skin"]',
    'Urine output reflects end-organ perfusion. Adequate: ≥0.5 mL/kg/hr (30 mL/hr in average adult). Also monitor: mental status, capillary refill, vital signs, skin turgor. Foley helps monitor critically ill patients.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9F019576-B4E6-41B2-BBA0-EF86E6623726',
    'Which instruction is important for a patient using a metered-dose inhaler (MDI)?',
    'Exhale completely, then inhale slowly and deeply while pressing canister',
    '["Inhale quickly and forcefully", "Hold breath for 1 second only", "Use without spacer even if prescribed"]',
    'MDI technique: shake, exhale fully, seal lips around mouthpiece (or spacer), press canister while inhaling slowly, hold breath 10 seconds. Spacer improves delivery. Rinse mouth after steroid inhalers to prevent thrush.',
    'Fundamentals',
    'Health Promotion',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '98D349A1-E20E-44D1-9D61-FB641E0C5643',
    'A patient is NPO for surgery. When should oral medications be given?',
    'With sips of water as ordered by the provider',
    '["Skip all medications", "Give with full glass of water", "Give with food as usual"]',
    'Essential medications (cardiac, BP, seizure) often continued with minimal water per provider order. Check preop orders specifically. Some medications held (anticoagulants, diabetic meds). Verify with provider and anesthesia.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1539FA42-9C4E-473F-B11D-E170EE33BCA7',
    'What is the appropriate response when a patient questions their medication?',
    'Thank them for being alert, verify the order, and explain the medication',
    '["Tell them to trust the nurse", "Give medication without discussion", "Become defensive"]',
    'Patients are partners in safety. Verify the 6 rights, check order, explain medication. If error found, thank patient, follow procedure. Patient questioning is a safety barrier, not a challenge to authority.',
    'Safety',
    'Safe & Effective Care',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A9C2E58A-F575-491D-A889-EF5DECA54BC7',
    'A postoperative patient has absent bowel sounds. What should the nurse document?',
    'Listen in all four quadrants for 2-5 minutes before documenting absent bowel sounds',
    '["Document immediately after 30 seconds", "Absent bowel sounds require no action", "This is always an emergency"]',
    'Bowel sounds may be hypoactive after surgery. Listen systematically in all 4 quadrants for at least 2-5 minutes total before documenting absence. Report absent sounds with abdominal distension or other concerning symptoms.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '7F23CBED-1530-4AD5-8618-2507938E4D82',
    'What is the normal serum sodium range?',
    '136-145 mEq/L',
    '["3.5-5.0 mEq/L", "98-106 mEq/L", "8.5-10.5 mg/dL"]',
    'Sodium 136-145 mEq/L. Hyponatremia: <136 (confusion, seizures). Hypernatremia: >145 (thirst, altered LOC). Potassium: 3.5-5.0. Chloride: 98-106. Calcium: 8.5-10.5 mg/dL.',
    'Fundamentals',
    'Physiological Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'E108491C-27EB-45ED-BE31-122D611CDE0F',
    'A patient develops hives and itching after starting an IV antibiotic. What is the FIRST action?',
    'Stop the infusion immediately',
    '["Slow the infusion rate", "Administer diphenhydramine and continue", "Wait to see if symptoms worsen"]',
    'Allergic reaction: stop medication immediately. Assess airway/breathing. Mild reaction: antihistamines. Severe/anaphylaxis: epinephrine, call rapid response. Keep IV access (change tubing). Document allergy in chart.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'C0C21333-231F-4F53-A94C-EA41C72F9BE8',
    'When obtaining a blood pressure, the cuff bladder should cover what percentage of the arm circumference?',
    '80% of the arm circumference',
    '["50% of the arm circumference", "100% of the arm circumference", "25% of the arm circumference"]',
    'Cuff bladder should cover 80% of arm circumference (width should be 40%). Too small cuff = falsely high reading. Too large = falsely low. Proper positioning: arm at heart level, patient relaxed 5 minutes before.',
    'Fundamentals',
    'Health Promotion',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '092BD2CA-A156-4325-90FA-E1F164C99D36',
    'A patient with a hearing impairment is being admitted. What is the BEST communication strategy?',
    'Face the patient, speak clearly at normal volume, reduce background noise',
    '["Shout loudly", "Write everything down only", "Speak rapidly to finish faster"]',
    'Face-to-face allows lip reading and visual cues. Speak clearly, normal pace and volume. Reduce background noise. Use written communication or interpreter as needed. Verify understanding. Don''t cover mouth.',
    'Fundamentals',
    'Psychosocial Integrity',
    'Easy',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '9E96DCF8-AD6A-4F19-B166-CFEE91163363',
    'What is the therapeutic range for INR in a patient on warfarin for atrial fibrillation?',
    '2.0-3.0',
    '["1.0-1.5", "3.5-4.5", "4.0-5.0"]',
    'INR 2.0-3.0 for most indications (A-fib, DVT, PE). Mechanical heart valves: 2.5-3.5. Higher INR = increased bleeding risk. Monitor regularly. Vitamin K rich foods (leafy greens) should be consistent, not avoided.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A387F94D-F7B5-4934-90E0-CB9144C1F5E2',
    'A confused patient keeps trying to climb out of bed. What is the MOST appropriate intervention?',
    'Use bed alarm and keep bed in lowest position with frequent checks',
    '["Apply bilateral wrist restraints", "Sedate the patient", "Place in a chair unsupervised"]',
    'Least restrictive measures first: bed alarm, low bed, frequent checks, non-slip footwear, toileting schedule, address underlying cause (pain, infection). Restraints are last resort and require order. Sitter if available.',
    'Safety',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '2586BB78-4B0D-48A5-856C-94B431000B25',
    'What is the appropriate nursing action for a patient with suspected opioid overdose?',
    'Administer naloxone, support respirations, and call for help',
    '["Give more pain medication", "Wait for symptoms to resolve", "Administer flumazenil"]',
    'Opioid overdose: respiratory depression, pinpoint pupils, unresponsiveness. Naloxone (Narcan) is antidote. Support airway/breathing. May need repeat doses (naloxone has shorter half-life than most opioids). Monitor for recurrence.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '1BD00DFC-BE5E-4E0B-8625-81B8947FA5AF',
    'A patient is receiving a continuous heparin infusion. What is the MOST important lab to monitor?',
    'Activated partial thromboplastin time (aPTT)',
    '["Prothrombin time (PT)", "INR", "Platelet count only"]',
    'aPTT monitors heparin therapy. Therapeutic: 1.5-2.5 times control. PT/INR monitors warfarin. Also monitor platelet count for heparin-induced thrombocytopenia (HIT). Signs of bleeding: bruising, blood in stool/urine.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '09B898A2-E9FA-41C2-8E60-5A08E42C5008',
    'What action is essential when administering blood products?',
    'Verify patient identity with two identifiers and have second nurse verify blood product',
    '["One nurse verification is sufficient", "Check ID once at the blood bank", "Start infusion at maximum rate"]',
    'Two nurses must verify: patient ID (2 identifiers), blood type, Rh factor, expiration, patient name on blood matches armband. Check vital signs before, 15 min into transfusion, and after. Transfusion reactions are preventable.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    '5E8859F8-7017-4F4E-8153-8221BE2A60E6',
    'What is the FIRST sign of infection in an elderly patient?',
    'Acute confusion or change in mental status',
    '["High fever", "Elevated white blood cell count", "Localized pain and swelling"]',
    'Elderly often have atypical infection presentation: may not have fever, WBC may be normal. Acute confusion/delirium is often first sign. Other subtle signs: decreased appetite, functional decline, falls. High suspicion needed.',
    'Fundamentals',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);
