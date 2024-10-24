-- Drop the table if it already exists
DROP TABLE IF EXISTS sapsii_req_features;

-- Create the new table with original features instead of discretized scores
CREATE TABLE sapsii_req_features AS
WITH cpap AS (
  SELECT ie.icustay_id,
         MIN(DATETIME_SUB(charttime, INTERVAL '1' HOUR)) AS starttime,
         MAX(DATETIME_ADD(charttime, INTERVAL '4' HOUR)) AS endtime,
         MAX(CASE
               WHEN LOWER(ce.value) LIKE '%cpap%' THEN 1
               WHEN LOWER(ce.value) LIKE '%bipap mask%' THEN 1
               ELSE 0
             END) AS cpap
    FROM icustays ie
         INNER JOIN chartevents ce
                 ON ie.icustay_id = ce.icustay_id
                AND ce.charttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
   WHERE itemid IN (467, 469, 226732)
     AND (LOWER(ce.value) LIKE '%cpap%' OR LOWER(ce.value) LIKE '%bipap mask%')
     AND (ce.error IS NULL OR ce.error = 0)
GROUP BY ie.icustay_id
),
surgflag AS (
  SELECT adm.hadm_id,
         CASE
           WHEN LOWER(curr_service) LIKE '%surg%' THEN 1
           ELSE 0
         END AS surgical,
         ROW_NUMBER() OVER (PARTITION BY adm.HADM_ID ORDER BY TRANSFERTIME) AS serviceOrder
    FROM admissions adm
         LEFT JOIN services se ON adm.hadm_id = se.hadm_id
),
comorb AS (
  SELECT hadm_id,
         MAX(CASE
               WHEN SUBSTR(icd9_code, 1, 3) BETWEEN '042' AND '044' THEN 1
             END) AS aids,
         MAX(CASE
               WHEN icd9_code BETWEEN '20000' AND '20238' THEN 1 -- lymphoma
               WHEN icd9_code BETWEEN '20240' AND '20248' THEN 1 -- leukemia
               WHEN icd9_code BETWEEN '20250' AND '20302' THEN 1 -- lymphoma
               WHEN icd9_code BETWEEN '20310' AND '20312' THEN 1 -- leukemia
               WHEN icd9_code BETWEEN '20302' AND '20382' THEN 1 -- lymphoma
               WHEN icd9_code BETWEEN '20400' AND '20522' THEN 1 -- chronic leukemia
               WHEN icd9_code BETWEEN '20580' AND '20702' THEN 1 -- other myeloid leukemia
               WHEN icd9_code BETWEEN '20720' AND '20892' THEN 1 -- other myeloid leukemia
               WHEN SUBSTR(icd9_code, 1, 4) = '2386' THEN 1 -- lymphoma
               WHEN SUBSTR(icd9_code, 1, 4) = '2733' THEN 1 -- lymphoma
             END) AS hem,
         MAX(CASE
               WHEN SUBSTR(icd9_code, 1, 4) BETWEEN '1960' AND '1991' THEN 1
               WHEN icd9_code BETWEEN '20970' AND '20975' THEN 1
               WHEN icd9_code = '20979' THEN 1
               WHEN icd9_code = '78951' THEN 1
             END) AS mets
    FROM diagnoses_icd
GROUP BY hadm_id
),
pafi1 AS (
  SELECT bg.icustay_id,
         bg.charttime,
         pao2fio2,
         CASE
           WHEN vd.icustay_id IS NOT NULL THEN 1
           ELSE 0
         END AS vent,
         CASE
           WHEN cp.icustay_id IS NOT NULL THEN 1
           ELSE 0
         END AS cpap
    FROM blood_gas_first_day_arterial bg
         LEFT JOIN ventilation_durations vd
                ON bg.icustay_id = vd.icustay_id
               AND bg.charttime BETWEEN vd.starttime AND vd.endtime
         LEFT JOIN cpap cp
                ON bg.icustay_id = cp.icustay_id
               AND bg.charttime BETWEEN cp.starttime AND cp.endtime
),
pafi2 AS (
  SELECT icustay_id,
         MIN(pao2fio2) AS pao2fio2_vent_min
    FROM pafi1
   WHERE vent = 1 OR cpap = 1
GROUP BY icustay_id
),
cohort AS (
  SELECT ie.subject_id,
         ie.hadm_id,
         ie.icustay_id,
         ie.intime,
         ie.outtime,
         DATETIME_DIFF(ie.intime, pat.dob, 'YEAR') AS age,
         vital.heartrate_max,
         vital.heartrate_min,
         vital.sysbp_max,
         vital.sysbp_min,
         vital.tempc_max,
         vital.tempc_min,
         pf.pao2fio2_vent_min,
         uo.urineoutput,
         labs.bun_min,
         labs.bun_max,
         labs.wbc_min,
         labs.wbc_max,
         labs.potassium_min,
         labs.potassium_max,
         labs.sodium_min,
         labs.sodium_max,
         labs.bicarbonate_min,
         labs.bicarbonate_max,
         labs.bilirubin_min,
         labs.bilirubin_max,
         gcs.mingcs,
         comorb.aids,
         comorb.hem,
         comorb.mets,
         CASE
           WHEN adm.ADMISSION_TYPE = 'ELECTIVE' AND sf.surgical = 1 THEN 'ScheduledSurgical'
           WHEN adm.ADMISSION_TYPE != 'ELECTIVE' AND sf.surgical = 1 THEN 'UnscheduledSurgical'
           ELSE 'Medical'
         END AS admissiontype
    FROM icustays ie
         INNER JOIN admissions adm ON ie.hadm_id = adm.hadm_id
         INNER JOIN patients pat ON ie.subject_id = pat.subject_id
         LEFT JOIN pafi2 pf ON ie.icustay_id = pf.icustay_id
         LEFT JOIN surgflag sf ON adm.hadm_id = sf.hadm_id AND sf.serviceOrder = 1
         LEFT JOIN comorb ON ie.hadm_id = comorb.hadm_id
         LEFT JOIN gcs_first_day gcs ON ie.icustay_id = gcs.icustay_id
         LEFT JOIN vitals_first_day vital ON ie.icustay_id = vital.icustay_id
         LEFT JOIN urine_output_first_day uo ON ie.icustay_id = uo.icustay_id
         LEFT JOIN labs_first_day labs ON ie.icustay_id = labs.icustay_id
)
SELECT cohort.subject_id,
       cohort.hadm_id,
       cohort.icustay_id,
       cohort.age,
       cohort.heartrate_max,
       cohort.heartrate_min,
       cohort.sysbp_max,
       cohort.sysbp_min,
       cohort.tempc_max,
       cohort.tempc_min,
       cohort.pao2fio2_vent_min,
       cohort.urineoutput,
       cohort.bun_min,
       cohort.bun_max,
       cohort.wbc_min,
       cohort.wbc_max,
       cohort.potassium_min,
       cohort.potassium_max,
       cohort.sodium_min,
       cohort.sodium_max,
       cohort.bicarbonate_min,
       cohort.bicarbonate_max,
       cohort.bilirubin_min,
       cohort.bilirubin_max,
       cohort.mingcs,
       cohort.aids,
       cohort.hem,
       cohort.mets,
       cohort.admissiontype
  FROM cohort
ORDER BY cohort.icustay_id;
