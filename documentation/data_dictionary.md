# Data Dictionary

## Patients
patient_id, patient_name, gender, date_of_birth, city, insurance_id

## Doctors
doctor_id, doctor_name, department_id, experience_years

## Encounters
encounter_id, patient_id, doctor_id, department_id, encounter_date, patient_type, status, wait_minutes, length_of_stay_days, encounter_cost, new_vs_returning, high_cost_flag, readmission_flag, cost_per_day, operational_priority

## Treatments
treatment_id, encounter_id, patient_id, treatment_type, quantity, unit_cost, treatment_cost

## Appointments
appointment_id, patient_id, doctor_id, department_id, appointment_date, appointment_type, status


`patient_id` is the primary analytical key. `patient_name` is used for readable patient-level reporting, Excel XLOOKUP practice, SQL JOIN output, and Power BI patient detail/drill-through views.
