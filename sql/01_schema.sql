CREATE TABLE dim_patient (
    patient_id VARCHAR(20) PRIMARY KEY,
    patient_name VARCHAR(100),
    gender VARCHAR(20),
    date_of_birth DATE,
    city VARCHAR(50),
    insurance_id VARCHAR(20)
);

CREATE TABLE dim_department (
    department_id VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE dim_doctor (
    doctor_id VARCHAR(20) PRIMARY KEY,
    doctor_name VARCHAR(100),
    department_id VARCHAR(20),
    experience_years INT
);

CREATE TABLE fact_encounter (
    encounter_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20),
    doctor_id VARCHAR(20),
    department_id VARCHAR(20),
    encounter_date DATE,
    patient_type VARCHAR(30),
    status VARCHAR(30),
    wait_minutes INT,
    length_of_stay_days INT,
    encounter_cost DECIMAL(12,2),
    new_vs_returning VARCHAR(20),
    high_cost_flag VARCHAR(20),
    readmission_flag VARCHAR(20),
    cost_per_day DECIMAL(12,2),
    operational_priority VARCHAR(20)
);

CREATE TABLE fact_treatment (
    treatment_id VARCHAR(20) PRIMARY KEY,
    encounter_id VARCHAR(20),
    patient_id VARCHAR(20),
    treatment_type VARCHAR(50),
    quantity INT,
    unit_cost DECIMAL(12,2),
    treatment_cost DECIMAL(12,2)
);

CREATE TABLE fact_appointment (
    appointment_id VARCHAR(20) PRIMARY KEY,
    patient_id VARCHAR(20),
    doctor_id VARCHAR(20),
    department_id VARCHAR(20),
    appointment_date DATE,
    appointment_type VARCHAR(50),
    status VARCHAR(30)
);
