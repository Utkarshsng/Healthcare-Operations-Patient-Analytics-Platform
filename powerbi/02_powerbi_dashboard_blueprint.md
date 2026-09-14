# Power BI Dashboard Blueprint

## Page 1 — Executive Operations Overview
Cards: Patients, Encounters, Completed Encounters, Avg Wait, Total Cost
Visuals: monthly encounters, encounters by department, cost by department
Slicers: Year, Department, Patient Type

## Page 2 — Patient & Encounter Intelligence
Visuals: new vs returning, encounter status, LOS distribution, high-cost encounters, readmission rate
Patient detail table: Patient ID, Patient Name, Gender, City, Total Encounters, Total Cost, Latest Encounter
Use `Dim_Patient[patient_name]` for readable patient-level reporting while `patient_id` remains the model key.

## Page 3 — Appointment & Department Operations
Visuals: appointment status, no-show rate by department, cancellation rate, doctor workload

## Page 4 — Cost, Readmission & Priority
Visuals: cost by department, high-cost encounters, priority cases, cost per day
