-- 1. Total patients
SELECT COUNT(DISTINCT patient_id) AS total_patients FROM dim_patient;

-- 2. Total encounters
SELECT COUNT(*) AS total_encounters FROM fact_encounter;

-- 3. Completed encounters
SELECT COUNT(*) AS completed_encounters FROM fact_encounter WHERE status='Completed';

-- 4. Department encounter volume
SELECT d.department_name, COUNT(*) AS encounters
FROM fact_encounter e JOIN dim_department d ON e.department_id=d.department_id
GROUP BY d.department_name ORDER BY encounters DESC;

-- 5. Average wait by department
SELECT d.department_name, ROUND(AVG(e.wait_minutes),2) AS avg_wait
FROM fact_encounter e JOIN dim_department d ON e.department_id=d.department_id
GROUP BY d.department_name ORDER BY avg_wait DESC;

-- 6. Total cost by department
SELECT d.department_name, ROUND(SUM(e.encounter_cost),2) AS total_cost
FROM fact_encounter e JOIN dim_department d ON e.department_id=d.department_id
GROUP BY d.department_name ORDER BY total_cost DESC;

-- 7. No-show rate
SELECT ROUND(100.0*SUM(CASE WHEN status='No Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate
FROM fact_appointment;

-- 8. Cancellation rate
SELECT ROUND(100.0*SUM(CASE WHEN status='Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS cancellation_rate
FROM fact_appointment;

-- 9. New vs returning encounters
SELECT new_vs_returning, COUNT(*) AS encounters
FROM fact_encounter GROUP BY new_vs_returning;

-- 10. Average LOS
SELECT ROUND(AVG(length_of_stay_days),2) AS avg_los FROM fact_encounter;

-- 11. High-cost encounters
SELECT COUNT(*) AS high_cost_encounters FROM fact_encounter WHERE high_cost_flag='High';

-- 12. Readmissions
SELECT COUNT(*) AS readmission_encounters FROM fact_encounter WHERE readmission_flag='Yes';

-- 13. Monthly encounter trend
SELECT EXTRACT(YEAR FROM encounter_date) AS yr, EXTRACT(MONTH FROM encounter_date) AS mn, COUNT(*) AS encounters
FROM fact_encounter GROUP BY EXTRACT(YEAR FROM encounter_date), EXTRACT(MONTH FROM encounter_date)
ORDER BY yr,mn;

-- 14. Top doctors by workload
SELECT doctor_id, COUNT(*) AS encounters
FROM fact_encounter GROUP BY doctor_id ORDER BY encounters DESC FETCH FIRST 10 ROWS ONLY;

-- 15. Doctors with above-average workload
SELECT doctor_id, COUNT(*) AS encounters
FROM fact_encounter GROUP BY doctor_id
HAVING COUNT(*) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) cnt FROM fact_encounter GROUP BY doctor_id) x);

-- 16. Priority encounters
SELECT operational_priority, COUNT(*) FROM fact_encounter GROUP BY operational_priority;

-- 17. Cost by patient type
SELECT patient_type, ROUND(AVG(encounter_cost),2) AS avg_cost
FROM fact_encounter GROUP BY patient_type;

-- 18. Treatment type cost
SELECT treatment_type, ROUND(SUM(treatment_cost),2) AS total_cost
FROM fact_treatment GROUP BY treatment_type ORDER BY total_cost DESC;

-- 19. Doctor rank within department
SELECT doctor_id, department_id, COUNT(*) AS encounters,
       DENSE_RANK() OVER(PARTITION BY department_id ORDER BY COUNT(*) DESC) AS dept_rank
FROM fact_encounter GROUP BY doctor_id, department_id;

-- 20. Running monthly encounters
WITH m AS (
 SELECT encounter_date, COUNT(*) AS daily_encounters
 FROM fact_encounter GROUP BY encounter_date
)
SELECT encounter_date, daily_encounters,
       SUM(daily_encounters) OVER(ORDER BY encounter_date) AS running_encounters
FROM m;

-- 21. Month-over-month daily reporting example
WITH m AS (
 SELECT EXTRACT(YEAR FROM encounter_date) yr, EXTRACT(MONTH FROM encounter_date) mn, COUNT(*) cnt
 FROM fact_encounter GROUP BY EXTRACT(YEAR FROM encounter_date), EXTRACT(MONTH FROM encounter_date)
)
SELECT yr,mn,cnt,LAG(cnt) OVER(ORDER BY yr,mn) AS previous_month
FROM m;

-- 22. Patients with 3+ encounters
SELECT patient_id, COUNT(*) AS encounters
FROM fact_encounter GROUP BY patient_id HAVING COUNT(*) >= 3;

-- 23. Emergency encounter cost
SELECT ROUND(SUM(encounter_cost),2) AS emergency_cost
FROM fact_encounter WHERE patient_type='Emergency';

-- 24. Average cost per encounter by department
SELECT d.department_name, ROUND(AVG(e.encounter_cost),2) AS avg_cost
FROM fact_encounter e JOIN dim_department d ON e.department_id=d.department_id
GROUP BY d.department_name;

-- 25. Top 10 patients by encounter cost
SELECT patient_id, ROUND(SUM(encounter_cost),2) AS total_cost
FROM fact_encounter GROUP BY patient_id ORDER BY total_cost DESC FETCH FIRST 10 ROWS ONLY;

-- 26. Department priority count
SELECT d.department_name, COUNT(*) AS priority_cases
FROM fact_encounter e JOIN dim_department d ON e.department_id=d.department_id
WHERE operational_priority='Priority' GROUP BY d.department_name ORDER BY priority_cases DESC;

-- 27. Appointment status mix
SELECT status, COUNT(*) AS appointments FROM fact_appointment GROUP BY status ORDER BY appointments DESC;

-- 28. Appointment volume by department
SELECT d.department_name, COUNT(*) AS appointments
FROM fact_appointment a JOIN dim_department d ON a.department_id=d.department_id
GROUP BY d.department_name ORDER BY appointments DESC;

-- 29. Average experience of doctors handling encounters
SELECT ROUND(AVG(d.experience_years),2) AS avg_experience
FROM fact_encounter e JOIN dim_doctor d ON e.doctor_id=d.doctor_id;

-- 30. Cost contribution by department
WITH c AS (
 SELECT department_id, SUM(encounter_cost) total_cost FROM fact_encounter GROUP BY department_id
)
SELECT d.department_name, total_cost,
       ROUND(100.0*total_cost/SUM(total_cost) OVER(),2) AS contribution_pct
FROM c JOIN dim_department d ON c.department_id=d.department_id
ORDER BY total_cost DESC;

-- 31. High-wait encounters
SELECT COUNT(*) AS high_wait_encounters FROM fact_encounter WHERE wait_minutes >= 60;

-- 32. Average treatment cost
SELECT ROUND(AVG(treatment_cost),2) AS avg_treatment_cost FROM fact_treatment;

-- 33. Most common treatment type
SELECT treatment_type, COUNT(*) AS treatment_count
FROM fact_treatment GROUP BY treatment_type ORDER BY treatment_count DESC FETCH FIRST 1 ROW ONLY;

-- 34. Latest encounter per patient
WITH x AS (
 SELECT e.*, ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY encounter_date DESC) rn
 FROM fact_encounter e
)
SELECT * FROM x WHERE rn=1;

-- 35. Departments above average encounter volume
WITH d AS (
 SELECT department_id, COUNT(*) cnt FROM fact_encounter GROUP BY department_id
)
SELECT d.department_id, d.cnt
FROM d WHERE cnt > (SELECT AVG(cnt) FROM d);

-- 36. Doctor workload and department
SELECT dr.doctor_name, dp.department_name, COUNT(e.encounter_id) workload
FROM dim_doctor dr
JOIN dim_department dp ON dr.department_id=dp.department_id
LEFT JOIN fact_encounter e ON dr.doctor_id=e.doctor_id
GROUP BY dr.doctor_name, dp.department_name
ORDER BY workload DESC;


-- 37. Patient-level report with patient names
SELECT p.patient_id, p.patient_name, COUNT(e.encounter_id) AS total_encounters, ROUND(SUM(e.encounter_cost),2) AS total_encounter_cost FROM dim_patient p LEFT JOIN fact_encounter e ON p.patient_id=e.patient_id GROUP BY p.patient_id,p.patient_name ORDER BY total_encounter_cost DESC;

-- 38. Top patients by encounter cost with readable names
SELECT p.patient_id,p.patient_name,ROUND(SUM(e.encounter_cost),2) AS total_cost FROM dim_patient p JOIN fact_encounter e ON p.patient_id=e.patient_id GROUP BY p.patient_id,p.patient_name ORDER BY total_cost DESC FETCH FIRST 10 ROWS ONLY;

-- 39. Patient name with latest encounter
WITH x AS (SELECT e.*,ROW_NUMBER() OVER(PARTITION BY e.patient_id ORDER BY e.encounter_date DESC) rn FROM fact_encounter e) SELECT p.patient_id,p.patient_name,x.encounter_id,x.encounter_date,x.encounter_cost,x.status FROM x JOIN dim_patient p ON x.patient_id=p.patient_id WHERE x.rn=1;
