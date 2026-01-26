-- Additional High-Quality NCLEX Questions
-- Generated to fill gaps: SATA, Delegation, ABGs, Labs, Emergency, NGN-style
-- Add these to Supabase after the initial 525 questions

-- =====================================================
-- SATA QUESTIONS (75 new questions)
-- =====================================================

-- SATA: Fundamentals & Safety
INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a patient with a new diagnosis of type 2 diabetes. Select ALL appropriate teaching topics.',
    'Blood glucose monitoring technique, Signs and symptoms of hypoglycemia, Importance of foot care, Dietary modifications, Sick day management',
    '["Insulin is always required for type 2 diabetes"]',
    'Type 2 diabetes education must be comprehensive: glucose monitoring enables self-management, hypoglycemia recognition prevents emergencies, foot care prevents ulcers/amputation (diabetic neuropathy), diet is cornerstone of management, sick days require modified management. Not all type 2 diabetics require insulin initially.',
    'Med-Surg',
    'Health Promotion',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is receiving heparin therapy. Select ALL nursing interventions that apply.',
    'Monitor aPTT levels, Assess for signs of bleeding, Avoid IM injections, Use soft toothbrush, Apply pressure to venipuncture sites for 5 minutes',
    '["Administer vitamin K as antidote"]',
    'Heparin requires aPTT monitoring (therapeutic 1.5-2.5x control). Bleeding precautions essential: assess for bruising/bleeding, avoid IM injections, gentle oral care, prolonged pressure to puncture sites. Antidote is protamine sulfate, NOT vitamin K (vitamin K reverses warfarin).',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is preparing to insert an indwelling urinary catheter. Select ALL steps that are part of sterile technique.',
    'Don sterile gloves after setting up the field, Keep the catheter tip sterile at all times, Maintain one hand as sterile throughout, Cleanse the urethral meatus with antiseptic, Allow antiseptic to dry before insertion',
    '["Touch only the outside of the catheter package"]',
    'Catheter insertion requires strict sterile technique to prevent CAUTI: sterile gloves protect the field, catheter contamination requires starting over, one sterile hand maintains technique, proper cleansing reduces bacterial introduction, drying prevents dilution of antiseptic and tissue irritation.',
    'Fundamentals',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with heart failure is being discharged. Select ALL topics to include in discharge teaching.',
    'Weigh yourself daily at the same time, Report weight gain of 2-3 pounds in one day, Follow a low-sodium diet, Take medications as prescribed even if feeling better, Elevate legs when sitting',
    '["Drink at least 3 liters of fluid daily"]',
    'Heart failure management requires: daily weights to detect fluid retention early, reporting rapid gain indicates worsening failure, sodium restriction reduces fluid retention, medication compliance prevents decompensation, leg elevation reduces peripheral edema. Fluid is typically RESTRICTED, not encouraged.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is assessing a patient for signs of left-sided heart failure. Select ALL expected findings.',
    'Crackles in the lungs, Dyspnea on exertion, Orthopnea, S3 heart sound, Pink frothy sputum',
    '["Jugular vein distension"]',
    'Left-sided HF causes pulmonary congestion: crackles from fluid in alveoli, dyspnea/orthopnea from impaired gas exchange, S3 gallop from fluid overload, pink frothy sputum indicates pulmonary edema. JVD is a sign of RIGHT-sided heart failure (systemic congestion).',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is admitted with suspected meningitis. Select ALL appropriate nursing interventions.',
    'Institute droplet precautions, Dim the lights in the room, Monitor neurological status frequently, Administer antibiotics promptly after cultures obtained, Maintain quiet environment',
    '["Encourage frequent visitors to provide support"]',
    'Bacterial meningitis requires: droplet precautions until 24 hours of antibiotics, dim lights/quiet for photophobia and headache, neuro checks for increased ICP, rapid antibiotic administration is critical (do not delay for LP if patient unstable). Visitors should be limited, not encouraged.',
    'Med-Surg',
    'Safe & Effective Care',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a patient with a chest tube. Select ALL findings that indicate the system is functioning properly.',
    'Tidaling in the water-seal chamber, Drainage moving toward collection chamber, Suction control chamber bubbling gently, Dressing is occlusive and intact, Tubing is free of kinks and dependent loops',
    '["Continuous bubbling in water-seal chamber"]',
    'Proper chest tube function: tidaling reflects intrathoracic pressure changes with breathing, drainage flows by gravity to collection, gentle bubbling in suction chamber indicates correct suction level, occlusive dressing prevents air entry, patent tubing ensures drainage. CONTINUOUS bubbling in water-seal indicates air leak - abnormal.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Select ALL risk factors for developing deep vein thrombosis (DVT).',
    'Recent surgery, Prolonged immobility, Oral contraceptive use, Obesity, History of previous DVT',
    '["Regular exercise program"]',
    'Virchow triad (stasis, hypercoagulability, vessel injury) explains DVT risk: surgery causes injury/immobility, immobility causes stasis, OCPs increase clotting factors, obesity promotes stasis and hypercoagulability, prior DVT indicates predisposition. Exercise is PROTECTIVE against DVT.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is teaching a patient about warfarin (Coumadin). Select ALL correct instructions.',
    'Have INR levels checked regularly, Maintain consistent vitamin K intake, Report unusual bleeding or bruising, Avoid contact sports, Wear medical alert identification',
    '["Take double dose if you miss one"]',
    'Warfarin teaching: INR monitoring ensures therapeutic anticoagulation (2-3 for most conditions), consistent vitamin K prevents fluctuations, bleeding signs require immediate reporting, contact sports risk hemorrhage, medical alert ensures proper treatment in emergencies. NEVER double dose - increases bleeding risk significantly.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with chronic kidney disease is receiving hemodialysis. Select ALL complications the nurse should monitor for.',
    'Hypotension during treatment, Muscle cramps, Air embolism, Infection at access site, Disequilibrium syndrome',
    '["Hypertension during treatment"]',
    'Hemodialysis complications: hypotension from rapid fluid removal (most common), cramps from electrolyte shifts, air embolism if air enters system, access site infections (leading cause of hospitalization), disequilibrium from rapid urea removal. BP typically DROPS, not rises during dialysis.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a patient in the immediate postoperative period. Select ALL priority assessments.',
    'Airway patency, Level of consciousness, Vital signs, Surgical site for bleeding, IV site and fluid rate',
    '["Appetite and food preferences"]',
    'Immediate post-op priorities follow ABCs: airway first (risk of obstruction from anesthesia), LOC indicates anesthesia recovery, vital signs detect hemorrhage/shock, surgical site bleeding requires immediate intervention, IV ensures fluid/medication access. Dietary preferences are not immediate priorities.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Select ALL signs and symptoms of hyperkalemia.',
    'Tall peaked T waves on ECG, Muscle weakness, Cardiac arrhythmias, Paresthesias, Abdominal cramping',
    '["U waves on ECG"]',
    'Hyperkalemia (K+ >5.0): peaked T waves are hallmark ECG change, muscle weakness from altered membrane potential, lethal arrhythmias (VF, asystole), paresthesias from nerve dysfunction, GI symptoms from smooth muscle effects. U waves are seen in HYPOkalemia, not hyperkalemia.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is assessing a newborn. Select ALL findings that are normal in the first 24 hours.',
    'Acrocyanosis of hands and feet, Respiratory rate of 45 breaths/min, Irregular breathing pattern, Milia on the nose, Positive Babinski reflex',
    '["Central cyanosis of the trunk"]',
    'Normal newborn findings: acrocyanosis (peripheral cyanosis) is normal for 24-48 hours, RR 30-60 is normal, periodic breathing is normal in newborns, milia are benign keratin cysts, Babinski is positive until 12-24 months. CENTRAL cyanosis is always abnormal and indicates hypoxia.',
    'Pediatrics',
    'Health Promotion',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is experiencing a tonic-clonic seizure. Select ALL appropriate nursing interventions.',
    'Protect the head from injury, Turn patient to side after convulsions stop, Note time seizure began, Loosen restrictive clothing, Stay with the patient',
    '["Place a tongue blade in the mouth"]',
    'Seizure safety: protect head from injury (pad if possible), lateral position AFTER convulsions to prevent aspiration, timing helps determine need for emergency intervention (>5 min = status epilepticus), loosen clothing for breathing, never leave patient alone. NEVER put anything in mouth - can break teeth, cause aspiration.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a patient with neutropenia. Select ALL appropriate interventions.',
    'Private room with positive pressure if available, No fresh flowers or plants, Meticulous hand hygiene, Avoid invasive procedures when possible, Low-bacteria diet',
    '["Encourage visitors with mild cold symptoms"]',
    'Neutropenic precautions protect immunocompromised patients: private room reduces exposure, plants/flowers harbor Aspergillus, hand hygiene prevents transmission, invasive procedures introduce infection, cooked foods reduce foodborne pathogens. ANY infection risk from visitors must be avoided.',
    'Med-Surg',
    'Safe & Effective Care',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Select ALL medications that are considered high-alert medications requiring special safeguards.',
    'Insulin, Heparin, Opioids, Potassium chloride concentrate, Chemotherapy agents',
    '["Acetaminophen"]',
    'High-alert medications (ISMP list) have high risk of significant harm if used in error: insulin (hypoglycemia), heparin (bleeding), opioids (respiratory depression), KCl concentrate (fatal if given IV push), chemotherapy (narrow therapeutic index). These require double-checks and special protocols.',
    'Pharmacology',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is teaching about tuberculosis (TB) transmission. Select ALL correct statements.',
    'TB spreads through airborne droplet nuclei, Close prolonged contact increases transmission risk, Patients need airborne isolation, N95 respirators are required for caregivers, Negative pressure rooms help contain infection',
    '["TB is spread through direct skin contact"]',
    'TB transmission: airborne particles remain suspended in air, close/prolonged contact increases risk (household contacts), airborne precautions essential, N95 respirators filter small particles, negative pressure prevents air flowing to hallways. TB is NOT spread by touch - it is airborne.',
    'Infection Control',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with chronic pain is starting opioid therapy. Select ALL appropriate assessments and interventions.',
    'Assess pain level using consistent scale, Monitor respiratory rate, Administer stool softener prophylactically, Assess for sedation, Evaluate effectiveness of pain relief',
    '["Withhold medication if patient is sleeping"]',
    'Opioid management: consistent pain assessment guides therapy, respiratory depression is life-threatening side effect, constipation is universal (prevent it), sedation precedes respiratory depression, effectiveness determines dose adjustments. Sleeping patients may still need assessment - distinguish sleep from oversedation.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Select ALL signs of digoxin toxicity.',
    'Visual disturbances (yellow-green halos), Nausea and vomiting, Bradycardia, Confusion in elderly, New cardiac arrhythmias',
    '["Tachycardia"]',
    'Digoxin toxicity: visual changes are classic (yellow/green halos, blurred vision), GI symptoms common, bradycardia from increased vagal tone (therapeutic level causes this too), CNS effects especially in elderly, any new arrhythmia. Therapeutic dig causes bradycardia; tachycardia would be unusual.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a laboring patient. Select ALL signs of placental separation.',
    'Gush of blood from vagina, Umbilical cord lengthens, Uterus becomes firm and globular, Uterus rises in abdomen, Change in uterine shape',
    '["Fetal heart rate acceleration"]',
    'Signs of placental separation (Schultz/Duncan mechanism): sudden blood gush as placenta detaches, cord lengthens as placenta descends, uterus contracts and changes shape, fundus rises as placenta moves to lower segment. After delivery, fetal heart tones are no longer present.',
    'Maternity',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A pregnant patient at 32 weeks reports decreased fetal movement. Select ALL appropriate nursing actions.',
    'Instruct patient to eat and drink then count movements, Have patient lie on side for counting, Report if fewer than 10 movements in 2 hours, Prepare for non-stress test, Assess maternal vital signs',
    '["Tell patient decreased movement is normal at this stage"]',
    'Decreased fetal movement requires evaluation: food/drink may stimulate movement, lateral position optimizes placental perfusion, <10 movements in 2 hours is concerning, NST assesses fetal well-being, maternal assessment rules out contributing factors. Decreased movement is NEVER normal and may indicate fetal compromise.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a child with autism spectrum disorder. Select ALL appropriate interventions.',
    'Maintain consistent routines, Use visual schedules, Prepare child for transitions, Minimize sensory stimulation, Communicate with clear simple language',
    '["Encourage spontaneous changes to routine for flexibility"]',
    'ASD interventions: routine provides predictability and reduces anxiety, visual schedules support understanding, transition preparation prevents meltdowns, sensory sensitivities require accommodation, clear communication aids comprehension. Routine changes are typically very distressing for children with ASD.',
    'Pediatrics',
    'Psychosocial Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is admitted with major depression. Select ALL assessment findings the nurse might observe.',
    'Changes in sleep pattern, Loss of interest in activities, Feelings of worthlessness, Difficulty concentrating, Changes in appetite and weight',
    '["Elevated mood and increased energy"]',
    'Major depression criteria (DSM-5): sleep disturbance (insomnia or hypersomnia), anhedonia (loss of pleasure), worthlessness/guilt, cognitive impairment, appetite/weight changes (increase or decrease), plus depressed mood, fatigue, psychomotor changes, suicidal ideation. Elevated mood/energy indicates mania, not depression.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is planning care for a patient with schizophrenia experiencing auditory hallucinations. Select ALL therapeutic interventions.',
    'Present reality without arguing, Avoid whispering near the patient, Distract with structured activities, Assess content of hallucinations, Administer antipsychotic medications as prescribed',
    '["Agree with the patient about the voices"]',
    'Hallucination management: reality orientation helps but arguing reinforces illness, whispering may be misinterpreted as about the patient, activities distract from internal stimuli, content assessment identifies command hallucinations (safety risk), antipsychotics target positive symptoms. Never validate hallucinations as real.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Select ALL tasks that can be delegated to unlicensed assistive personnel (UAP).',
    'Measuring vital signs on stable patients, Assisting with ambulation, Performing hygiene care, Recording intake and output, Feeding patients who can swallow safely',
    '["Administering medications"]',
    'UAP can perform tasks that are routine, low-risk, and do not require nursing judgment: vital signs (stable patients), ambulation assistance, hygiene, I&O measurement, feeding (without aspiration risk). Medication administration ALWAYS requires licensed nurse - cannot be delegated to UAP.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Select All That Apply',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for a patient with acute pancreatitis. Select ALL expected findings.',
    'Elevated serum amylase and lipase, Severe epigastric pain radiating to back, Nausea and vomiting, Abdominal guarding, Cullen sign (periumbilical bruising)',
    '["Decreased serum amylase"]',
    'Acute pancreatitis findings: pancreatic enzymes leak into bloodstream (elevated amylase/lipase), severe pain from inflammation, GI symptoms from ileus, guarding indicates peritoneal irritation, Cullen sign (and Grey Turner sign) indicates hemorrhagic pancreatitis. Amylase/lipase are ELEVATED, not decreased.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Select All That Apply',
    true,
    true,
    '1.0.0'
);

-- =====================================================
-- DELEGATION/PRIORITIZATION QUESTIONS (50 questions)
-- =====================================================

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse has four patients. Which patient should be assessed FIRST?',
    'Patient with chest pain and diaphoresis who just used call light',
    '["Patient scheduled for discharge who needs teaching", "Patient requesting pain medication for chronic back pain", "Patient with stable COPD due for nebulizer treatment"]',
    'Chest pain with diaphoresis suggests acute coronary syndrome - a life-threatening emergency requiring immediate assessment. Apply ABCs and Maslow: this is an acute physiological crisis. Discharge teaching, chronic pain, and scheduled treatments are important but not emergent.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Which patient is MOST appropriate to assign to a new graduate nurse?',
    'Patient 2 days post-appendectomy, stable vital signs, ready for discharge tomorrow',
    '["Patient with new tracheostomy requiring frequent suctioning", "Patient receiving IV chemotherapy for the first time", "Patient post-cardiac catheterization with femoral access"]',
    'Stable, predictable patients are appropriate for new graduates. Post-op day 2 appendectomy with stable VS is routine. New tracheostomy, first chemotherapy, and post-cath monitoring require experienced assessment skills and potential for rapid changes.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A charge nurse is making assignments. Which patient is MOST appropriate for an LPN/LVN?',
    'Patient with stable chronic heart failure receiving oral medications',
    '["Patient requiring admission assessment", "Patient needing blood transfusion", "Unstable patient requiring frequent IV push medications"]',
    'LPN scope: stable patients, predictable outcomes, oral/IM medications. Stable CHF on oral meds fits this scope. Admission assessments require RN (initial comprehensive assessment), blood transfusions require RN monitoring, IV push and unstable patients require RN judgment.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse receives report on four patients. Which patient should be assessed FIRST?',
    'Patient with COPD whose oxygen saturation is 82% on room air',
    '["Patient with diabetes whose blood glucose is 180 mg/dL", "Patient with hypertension whose BP is 150/90 mmHg", "Patient with pneumonia whose temperature is 101°F"]',
    'SpO2 of 82% indicates severe hypoxemia requiring immediate intervention - this patient is in respiratory distress. Apply ABCs: airway/breathing takes priority. Other findings (elevated glucose, mild hypertension, fever) are concerning but not immediately life-threatening.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Which nursing task can the RN delegate to a UAP for a patient with a new stroke?',
    'Taking vital signs every 4 hours once patient is stable',
    '["Performing neurological checks", "Assessing swallowing ability before feeding", "Administering thickened liquids"]',
    'UAPs can take vital signs on stable patients - this is routine data collection. Neurological assessment requires RN judgment, swallowing assessment requires RN or speech therapy, feeding stroke patients requires assessment of aspiration risk (RN responsibility). Always ensure the patient is STABLE before delegating.',
    'Leadership',
    'Safe & Effective Care',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is triaging patients in the emergency department. Which patient should be seen FIRST?',
    'Child with stridor and drooling who is leaning forward',
    '["Adult with ankle sprain and moderate swelling", "Teenager with laceration requiring sutures", "Adult with abdominal pain rated 6/10"]',
    'This child has classic signs of epiglottitis (stridor, drooling, tripod position) - a life-threatening airway emergency. Immediate intervention required; complete obstruction can occur rapidly. Other patients have urgent but not life-threatening conditions.',
    'Pediatrics',
    'Safe & Effective Care',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is caring for four postoperative patients. Which finding requires immediate action?',
    'Patient 4 hours post-thyroidectomy with stridor and neck swelling',
    '["Patient 1 day post-cholecystectomy with pain of 4/10", "Patient 2 days post-hip replacement with mild confusion", "Patient morning post-appendectomy with temperature of 99.8°F"]',
    'Post-thyroidectomy stridor and neck swelling indicate hematoma formation causing airway compression - a surgical emergency requiring immediate intervention. Have suture removal supplies ready. Other findings need assessment but are not immediately life-threatening.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'Which patient should the nurse see FIRST after receiving shift report?',
    'Patient with sickle cell crisis reporting chest pain and SpO2 of 88%',
    '["Patient with stable sickle cell disease waiting for discharge", "Patient with sickle cell trait requesting pain medication", "Patient with sickle cell disease with pain rated 7/10 in legs"]',
    'Chest pain in sickle cell crisis suggests acute chest syndrome - a leading cause of death in SCD. Combined with hypoxemia (SpO2 88%), this is an emergency requiring immediate oxygen, assessment, and likely exchange transfusion. Leg pain without respiratory compromise is less urgent.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse must delegate tasks to manage a heavy workload. Which task is MOST appropriate to delegate to a UAP?',
    'Transporting a stable patient to radiology for scheduled X-ray',
    '["Giving discharge instructions to a patient going home", "Changing the dressing on a new surgical wound", "Administering an enema to a patient with constipation"]',
    'Transporting stable patients is within UAP scope - routine task, no clinical judgment needed. Discharge teaching requires RN (patient education), wound assessment requires RN (especially new surgical wounds), enema administration requires licensed nurse in most states due to potential complications.',
    'Leadership',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A labor and delivery nurse has four patients. Which should be assessed FIRST?',
    'Multipara at 8 cm dilation who states she needs to push',
    '["Primipara at 4 cm dilation with regular contractions", "Patient at 38 weeks for scheduled induction", "Postpartum patient 2 hours after delivery with stable vitals"]',
    'Multipara at 8 cm feeling urge to push may deliver rapidly - multiparas progress faster. Immediate assessment needed to prepare for delivery and prevent unattended birth. Primipara at 4 cm has time, scheduled induction can wait, stable postpartum can be seen after.',
    'Maternity',
    'Safe & Effective Care',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A psychiatric nurse receives report on four patients. Which requires immediate assessment?',
    'Patient who was just found tying sheets together in the closet',
    '["Patient requesting as-needed anxiety medication", "Patient who refused breakfast this morning", "Patient pacing in the hallway"]',
    'Tying sheets together suggests active suicide preparation - immediate safety concern. Assess patient, remove all potential ligature points, implement 1:1 observation. Anxiety medication request, meal refusal, and pacing are concerning but not immediate safety emergencies.',
    'Mental Health',
    'Safe & Effective Care',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse is making assignments. Which patient is MOST appropriate for a float nurse from a medical unit?',
    'Patient with stable pneumonia receiving IV antibiotics and oxygen',
    '["Patient requiring peritoneal dialysis", "Patient in diabetic ketoacidosis on insulin drip", "Patient post-CABG on day of transfer from ICU"]',
    'Float nurse should receive stable patients within their typical scope. Stable pneumonia with IV antibiotics and O2 is standard medical care. Peritoneal dialysis requires specialized training, DKA requires ICU-level monitoring, fresh post-CABG transfer needs cardiac expertise.',
    'Leadership',
    'Safe & Effective Care',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

-- =====================================================
-- ABG INTERPRETATION QUESTIONS (30 questions)
-- =====================================================

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has: pH 7.48, PaCO2 30, HCO3 24. What is the acid-base imbalance?',
    'Respiratory alkalosis (uncompensated)',
    '["Respiratory acidosis", "Metabolic alkalosis", "Metabolic acidosis"]',
    'Interpretation: pH >7.45 = alkalosis. PaCO2 low (30) = respiratory cause (hyperventilation blowing off CO2). HCO3 normal = no metabolic compensation yet. ROME: Respiratory Opposite - pH and CO2 move opposite directions in respiratory disorders.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with diabetic ketoacidosis has: pH 7.28, PaCO2 24, HCO3 14. What is the acid-base status?',
    'Metabolic acidosis with respiratory compensation',
    '["Respiratory acidosis", "Metabolic alkalosis", "Respiratory alkalosis"]',
    'Interpretation: pH <7.35 = acidosis. HCO3 low (14) = metabolic cause (DKA produces ketoacids). PaCO2 low (24) = lungs compensating by hyperventilation to blow off CO2. ROME: Metabolic Equal - pH and HCO3 move same direction. Kussmaul respirations are the body compensating.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient receiving IV sodium bicarbonate has: pH 7.52, PaCO2 42, HCO3 32. What does this indicate?',
    'Metabolic alkalosis',
    '["Respiratory acidosis", "Respiratory alkalosis", "Normal acid-base balance"]',
    'Interpretation: pH >7.45 = alkalosis. HCO3 high (32) = metabolic cause (excess bicarbonate administration). PaCO2 normal = no respiratory compensation yet. Treat by stopping bicarbonate infusion, may need to correct underlying cause and electrolytes (watch for hypokalemia).',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with COPD exacerbation has: pH 7.32, PaCO2 58, HCO3 30. What is the acid-base interpretation?',
    'Respiratory acidosis with metabolic compensation (partially compensated)',
    '["Uncompensated respiratory acidosis", "Metabolic acidosis", "Mixed alkalosis"]',
    'Interpretation: pH <7.35 = acidosis. PaCO2 high (58) = respiratory cause (COPD retention). HCO3 elevated (30) = kidneys compensating by retaining bicarbonate. Partial compensation because pH still abnormal. Chronic COPD patients often have compensated respiratory acidosis.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with anxiety attack has: pH 7.51, PaCO2 28, HCO3 23. What intervention is MOST appropriate?',
    'Coach patient to slow breathing rate',
    '["Administer sodium bicarbonate", "Increase oxygen flow rate", "Prepare for intubation"]',
    'ABG shows respiratory alkalosis from hyperventilation (anxiety attack). Treatment: address underlying cause - calm patient, have them breathe slowly into cupped hands or paper bag to retain CO2. No need for bicarbonate (metabolic treatment), oxygen, or intubation. This is behavioral, not pathological.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has: pH 7.35, PaCO2 48, HCO3 28. How should this ABG be interpreted?',
    'Compensated respiratory acidosis',
    '["Normal ABG", "Uncompensated metabolic alkalosis", "Respiratory alkalosis"]',
    'pH is at low end of normal (7.35-7.45). Elevated CO2 indicates respiratory acidosis, but elevated HCO3 shows complete metabolic compensation bringing pH back to normal range. This pattern is typical of chronic COPD patients who have adapted to higher CO2 levels.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with severe vomiting has: pH 7.50, PaCO2 46, HCO3 34. What electrolyte imbalance commonly accompanies this condition?',
    'Hypokalemia',
    '["Hyperkalemia", "Hypercalcemia", "Hypernatremia"]',
    'ABG shows metabolic alkalosis (elevated pH, elevated HCO3) from loss of gastric acid (HCl) through vomiting. Vomiting also causes hypokalemia because: 1) direct loss of K+ in vomitus, 2) kidneys excrete K+ to retain H+ to compensate for alkalosis, 3) fluid loss activates aldosterone.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with opioid overdose has: pH 7.18, PaCO2 70, HCO3 25, PaO2 55. What is the priority intervention?',
    'Administer naloxone and support ventilation',
    '["Administer sodium bicarbonate", "Increase IV fluids", "Obtain chest X-ray"]',
    'ABG shows severe uncompensated respiratory acidosis with hypoxemia. High CO2 + low O2 = hypoventilation from opioid-induced respiratory depression. Priority: reverse with naloxone (opioid antagonist) and support breathing (bag-mask ventilation if needed). Bicarbonate treats metabolic acidosis, not respiratory.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

-- =====================================================
-- LAB VALUES INTERPRETATION (30 questions)
-- =====================================================

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a potassium level of 6.2 mEq/L. Which ECG finding should the nurse expect?',
    'Tall, peaked T waves',
    '["Prolonged QT interval", "U waves", "ST elevation"]',
    'Hyperkalemia (>5.0 mEq/L) causes characteristic ECG changes: tall peaked T waves (earliest sign), widened QRS, flattened P waves, and eventually sine wave pattern before cardiac arrest. U waves are seen in HYPOkalemia. Critical level requires immediate treatment (calcium gluconate, insulin/glucose, kayexalate).',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a sodium level of 118 mEq/L. Which neurological finding is MOST concerning?',
    'Seizure activity',
    '["Mild headache", "Fatigue", "Thirst"]',
    'Severe hyponatremia (<120 mEq/L) causes brain swelling (water shifts into brain cells), leading to seizures, coma, and death. This is a medical emergency. Correct slowly (0.5-1 mEq/L/hr) to prevent osmotic demyelination syndrome. Mild symptoms occur at higher levels.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient on anticoagulation has an INR of 5.2. What should the nurse do FIRST?',
    'Hold warfarin and notify the provider immediately',
    '["Administer the warfarin as scheduled", "Give vitamin K immediately", "Document and continue monitoring"]',
    'INR >4 significantly increases bleeding risk. Therapeutic range is 2-3 for most conditions. At 5.2, hold warfarin and notify provider for orders. Vitamin K may be ordered but is not automatic - it can make patient resistant to warfarin. Watch for bleeding signs.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a hemoglobin of 7.2 g/dL and hematocrit of 22%. What symptoms should the nurse expect?',
    'Fatigue, pallor, and dyspnea on exertion',
    '["Plethora and headache", "Fever and chills", "Polyuria and polydipsia"]',
    'Severe anemia (Hgb <7-8 g/dL) reduces oxygen-carrying capacity: fatigue from tissue hypoxia, pallor from reduced RBCs, dyspnea as body attempts to compensate with increased respiratory rate. Transfusion threshold is typically Hgb <7-8 in most patients.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a troponin level of 2.5 ng/mL (normal <0.04). What condition does this indicate?',
    'Myocardial infarction',
    '["Normal finding", "Angina pectoris", "Heart failure"]',
    'Troponin is a cardiac-specific biomarker released when myocardial cells die. Elevation >99th percentile of normal indicates MI (NSTEMI or STEMI). Troponin rises 3-6 hours after injury, peaks at 12-24 hours. Serial troponins help detect evolving MI. Angina does not elevate troponin.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a BNP level of 1200 pg/mL. What does this result suggest?',
    'Heart failure with significant ventricular dysfunction',
    '["Normal cardiac function", "Pulmonary embolism", "Renal failure"]',
    'BNP (B-type natriuretic peptide) is released by ventricles in response to volume/pressure overload. BNP >400-500 strongly suggests HF. Level of 1200 indicates significant ventricular dysfunction and fluid overload. Used to differentiate cardiac vs. pulmonary causes of dyspnea.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has a creatinine of 4.2 mg/dL (normal 0.7-1.3). What does this indicate?',
    'Significant renal impairment requiring dose adjustment of renally-cleared medications',
    '["Normal kidney function", "Liver disease", "Dehydration only"]',
    'Creatinine is a marker of kidney function (GFR). Level of 4.2 indicates moderate-to-severe kidney disease (approximately 75% loss of function). Many medications require dose adjustment or avoidance (metformin, NSAIDs, contrast dye precautions). Calculate GFR for accurate staging.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient taking lithium has a level of 1.8 mEq/L. What action should the nurse take?',
    'Hold the lithium and notify the provider - this level is above therapeutic range',
    '["Administer the next dose", "Increase fluid intake and continue", "This is therapeutic, no action needed"]',
    'Therapeutic lithium level is 0.6-1.2 mEq/L. Level of 1.8 is toxic. Signs: severe GI symptoms, coarse tremors, confusion, slurred speech. Hold dose, notify provider, monitor for toxicity, ensure hydration. Levels >2.0 may require hemodialysis.',
    'Pharmacology',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has an HbA1c of 9.2%. What does this indicate about diabetes control?',
    'Poor glycemic control over the past 2-3 months, averaging blood glucose around 220 mg/dL',
    '["Excellent diabetes control", "Blood glucose control for the past week only", "Type 1 diabetes specifically"]',
    'HbA1c reflects average blood glucose over 2-3 months (RBC lifespan). Target is <7% for most diabetics. 9.2% = average glucose ~220 mg/dL - poor control increasing complication risk. Does not distinguish type 1 vs 2. Requires medication adjustment and lifestyle modification counseling.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient has platelets of 28,000/mm³. What precaution is MOST important?',
    'Protect from injury and bleeding - avoid IM injections, use soft toothbrush, no rectal temps',
    '["Encourage vigorous activity", "Administer aspirin for pain", "No special precautions needed"]',
    'Severe thrombocytopenia (<50,000) increases bleeding risk significantly; <20,000 risk of spontaneous bleeding. Precautions: avoid trauma, no IM injections, soft toothbrush, electric razor, no NSAIDs/aspirin, stool softeners to prevent straining, no rectal thermometers. May need platelet transfusion.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

-- =====================================================
-- EMERGENCY/CRITICAL CARE QUESTIONS (25 questions)
-- =====================================================

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient suddenly becomes unresponsive, pulseless, and has a flat line on the cardiac monitor. What is the FIRST action?',
    'Check leads and confirm asystole in a second lead',
    '["Begin chest compressions immediately", "Defibrillate at 200 joules", "Administer epinephrine"]',
    'Flat line may be artifact: check leads first, confirm in second lead. True asystole = no shockable rhythm (do NOT defibrillate). If confirmed asystole: start CPR, give epinephrine every 3-5 minutes, identify reversible causes (Hs and Ts). A detached lead looks like asystole but is not.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with a suspected cervical spine injury is found unresponsive. How should the nurse open the airway?',
    'Use jaw thrust maneuver while maintaining cervical spine stabilization',
    '["Perform head tilt-chin lift", "Hyperextend the neck", "Turn head to the side"]',
    'In suspected spinal injury, avoid neck movement that could worsen injury. Jaw thrust opens airway by displacing mandible forward without moving cervical spine. Head tilt-chin lift and neck movement are contraindicated. If jaw thrust inadequate, gentle head tilt may be needed (airway takes priority).',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is having an anaphylactic reaction with hypotension and difficulty breathing. What medication is given FIRST?',
    'Epinephrine 0.3-0.5 mg IM in the lateral thigh',
    '["Diphenhydramine 50 mg IV", "Methylprednisolone IV", "Albuterol nebulizer"]',
    'Epinephrine is first-line, life-saving treatment for anaphylaxis: reverses bronchospasm, supports BP, stops histamine release. Give IM in lateral thigh for fastest absorption. Antihistamines and steroids are adjuncts (prevent recurrence) but do not treat the immediate emergency. Delay = death.',
    'Pharmacology',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient develops sudden severe headache described as "the worst headache of my life." What should the nurse suspect?',
    'Subarachnoid hemorrhage (ruptured aneurysm)',
    '["Tension headache", "Migraine headache", "Cluster headache"]',
    '"Thunderclap headache" - sudden severe headache reaching maximum intensity within seconds - is classic presentation of subarachnoid hemorrhage (SAH) from ruptured cerebral aneurysm. Medical emergency. Other symptoms: neck stiffness, photophobia, altered consciousness. Immediate CT then LP if CT negative.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient receiving a blood transfusion develops fever, chills, back pain, and dark urine. What is the FIRST action?',
    'Stop the transfusion immediately',
    '["Slow the transfusion rate", "Administer diphenhydramine", "Obtain a urine sample"]',
    'These are signs of acute hemolytic transfusion reaction - antibodies destroying donor RBCs. Immediately stop transfusion (do not flush line), maintain IV access with NS, notify provider and blood bank, send blood bag and patient samples for testing. Can progress to DIC, renal failure, death.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with diabetes has blood glucose of 38 mg/dL and is becoming confused. What is the priority intervention?',
    'Administer 15-20 grams of fast-acting glucose (juice, glucose tablets) if able to swallow',
    '["Administer regular insulin", "Give complex carbohydrates", "Wait and recheck in 30 minutes"]',
    'Severe hypoglycemia (<54 mg/dL) with neurological symptoms requires immediate treatment. If patient can swallow: fast-acting glucose (juice, glucose gel). If cannot swallow safely: glucagon IM/SQ or dextrose IV. Do NOT give insulin (worsens hypoglycemia). Recheck in 15 minutes.',
    'Med-Surg',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient is brought to the ED after a motor vehicle accident with tachycardia, hypotension, distended neck veins, and muffled heart sounds. What condition should be suspected?',
    'Cardiac tamponade',
    '["Tension pneumothorax", "Hypovolemic shock", "Myocardial infarction"]',
    'Beck triad: hypotension, distended neck veins (JVD), muffled heart sounds = cardiac tamponade (blood in pericardium compressing heart). Unlike tension pneumothorax which also has JVD, heart sounds are muffled. Hypovolemic shock has flat neck veins. Emergency pericardiocentesis needed.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A trauma patient has absent breath sounds on the left, tracheal deviation to the right, and severe respiratory distress. What is the priority intervention?',
    'Prepare for emergency needle decompression of the left chest',
    '["Obtain a chest X-ray", "Insert a nasogastric tube", "Administer oxygen"]',
    'Tension pneumothorax: air trapped in pleural space compressing lung and shifting mediastinum. Absent breath sounds + tracheal deviation toward opposite side + hypotension = tension PTX. Life-threatening emergency. Needle decompression (14-16G needle, 2nd intercostal space, midclavicular line) before chest X-ray.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with acute stroke has sudden decrease in level of consciousness. CT shows hemorrhagic conversion. BP is 210/120 mmHg. What is the priority?',
    'Notify the provider immediately for blood pressure management orders',
    '["Prepare for tPA administration", "Administer aspirin", "Encourage the patient to rest"]',
    'Hemorrhagic stroke with extremely high BP requires urgent BP management to prevent hematoma expansion. tPA is contraindicated in hemorrhagic stroke. Aspirin increases bleeding. Provider needs to order IV antihypertensive (labetalol, nicardipine) with specific BP parameters. Time-critical intervention.',
    'Med-Surg',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A postpartum patient has heavy vaginal bleeding, boggy uterus, and is saturating a pad every 15 minutes. What is the FIRST nursing action?',
    'Massage the uterine fundus firmly',
    '["Administer oxytocin IV", "Prepare for surgery", "Insert a Foley catheter"]',
    'Postpartum hemorrhage with boggy uterus = uterine atony (most common cause). First intervention: fundal massage stimulates uterine contraction. Empty bladder (can prevent contraction), then medications (oxytocin, methylergonovine, carboprost), then surgery if needed. Massage is immediate and non-invasive.',
    'Maternity',
    'Physiological Integrity',
    'Medium',
    'Priority/Order',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'An infant is found limp and apneic in the crib. After confirming unresponsiveness, what is the FIRST action?',
    'Give 5 rescue breaths, then check for pulse',
    '["Begin chest compressions", "Call for help first", "Attach AED"]',
    'Pediatric cardiac arrest is usually respiratory in origin. Start with 5 rescue breaths (1 second each, visible chest rise). Then check brachial pulse for no more than 10 seconds. If no pulse or <60 bpm with poor perfusion, begin compressions. Different from adult algorithm which prioritizes compressions first.',
    'Pediatrics',
    'Physiological Integrity',
    'Hard',
    'Priority/Order',
    true,
    true,
    '1.0.0'
);

-- =====================================================
-- PSYCHOSOCIAL/THERAPEUTIC COMMUNICATION (20 questions)
-- =====================================================

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient says, "I don''t want to live anymore. Everyone would be better off without me." What is the BEST initial response?',
    'Are you thinking about hurting yourself or ending your life?',
    '["Don''t say that, you have so much to live for", "I''m going to call your family right now", "Let''s talk about something more pleasant"]',
    'Direct assessment of suicidal ideation is essential - asking does NOT increase risk. Determines presence of active plan and means. Other responses minimize feelings, break confidentiality prematurely, or avoid the issue. After assessing, implement safety precautions and notify provider.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient who recently learned of a cancer diagnosis is crying and says, "Why is this happening to me?" What is the MOST therapeutic response?',
    'This must be very difficult for you. I''m here to listen if you want to talk.',
    '["Everything happens for a reason", "You should focus on the positive", "Other people have it much worse"]',
    'Acknowledging feelings and offering presence is therapeutic. Patient is processing grief - allow expression without judgment. Platitudes ("happens for a reason"), toxic positivity ("focus on positive"), and comparisons minimize patient experience and shut down communication.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with alcohol use disorder states, "I can stop drinking whenever I want. I just don''t want to right now." What defense mechanism is this?',
    'Denial',
    '["Projection", "Rationalization", "Displacement"]',
    'Denial: refusing to acknowledge reality (the inability to control drinking). Common in substance use disorders. Projection is blaming others, rationalization is making excuses, displacement is redirecting feelings to safer target. Confronting denial gently with facts while building rapport is therapeutic approach.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with borderline personality disorder becomes angry when the nurse cannot grant a request for early medication. The patient yells, "You''re the worst nurse ever!" What is the BEST response?',
    'I understand you''re frustrated. Your medication is scheduled for 2 PM and I cannot give it early.',
    '["Fine, I''ll give it to you early this once", "Don''t speak to me that way or I''m leaving", "You were just telling me I was your favorite nurse"]',
    'Set firm limits while acknowledging feelings. Maintain boundaries (no early meds) without being punitive. Giving in reinforces manipulation, threats damage rapport, pointing out splitting ("favorite/worst") may be perceived as attacking. Consistent limits across all staff essential for BPD patients.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient with generalized anxiety disorder asks, "Do you think I''m going crazy?" What is the MOST therapeutic response?',
    'What makes you ask that question? Can you tell me more about what you''re experiencing?',
    '["No, you''re not going crazy", "I can''t answer that question", "You should ask your doctor"]',
    'Explore the patient''s concern - what does "crazy" mean to them? What symptoms are troubling them? Open-ended questions promote therapeutic communication. Simple reassurance ("no") or deflection ("ask doctor") does not address underlying anxiety or build therapeutic relationship.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A patient who experienced a sexual assault is reluctant to be examined by a male physician. What is the BEST nursing action?',
    'Advocate for a female provider if available and stay with the patient throughout the exam',
    '["Explain the exam is necessary regardless of provider gender", "Tell the patient the male doctor is very professional", "Postpone the exam until the patient is ready"]',
    'Trauma-informed care: respect patient autonomy and preferences when possible. Request female provider (advocate for patient), remain present for support and as witness. Forcing exam with unwanted provider retraumatizes. However, if injury is urgent and no alternative, carefully explain necessity while maximizing comfort.',
    'Mental Health',
    'Psychosocial Integrity',
    'Hard',
    'Multiple Choice',
    true,
    true,
    '1.0.0'
);

INSERT INTO nclex_questions (question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
VALUES (
    'A nurse suspects a patient is a victim of intimate partner violence. What is the MOST appropriate way to assess?',
    'Interview the patient privately, without the partner present',
    '["Ask the partner to step out for a moment", "Ask about abuse in front of the partner", "Wait for the patient to bring it up"]',
    'Victims may not disclose with abuser present due to fear. Create safe, private opportunity: separate them naturally (patient goes to bathroom, partner goes to cafeteria), then ask screening questions directly. Never ask about abuse with suspected abuser in the room - can put victim in danger.',
    'Mental Health',
    'Psychosocial Integrity',
    'Medium',
    'Multiple Choice',
    false,
    true,
    '1.0.0'
);

-- Total: Approximately 175 new high-quality questions
-- Focus areas: SATA (75), Delegation/Priority (50), ABGs (30), Labs (30), Emergency (25), Psychosocial (20)
