import pandas as pd

RAW = "../data/raw"
CLEAN = "../data/cleaned"

enc = pd.read_csv(f"{RAW}/encounters_raw.csv")
enc["status"] = enc["status"].astype(str).str.strip().str.title()

valid = (
    enc["wait_minutes"].ge(0)
    & enc["encounter_cost"].ge(0)
    & enc["department_id"].isin(pd.read_csv(f"{RAW}/departments_raw.csv")["department_id"])
)

clean = enc.loc[valid].drop_duplicates("encounter_id").copy()
clean["new_vs_returning"] = clean.groupby("patient_id").cumcount().eq(0).map({True:"New",False:"Returning"})
clean["high_cost_flag"] = (clean["encounter_cost"] >= clean["encounter_cost"].quantile(.90)).map({True:"High",False:"Normal"})
clean["readmission_flag"] = clean["patient_id"].duplicated(keep=False).map({True:"Yes",False:"No"})
clean["cost_per_day"] = clean["encounter_cost"].div(clean["length_of_stay_days"].replace(0,1))
clean["operational_priority"] = ((clean["wait_minutes"] >= 60) | (clean["high_cost_flag"]=="High")).map({True:"Priority",False:"Standard"})

clean.to_csv(f"{CLEAN}/encounters.csv", index=False)
print("Cleaned encounter rows:", len(clean))
