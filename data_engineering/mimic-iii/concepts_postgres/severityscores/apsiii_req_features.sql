-- Drop the table if it already exists
DROP TABLE IF EXISTS apsiii_req_features;

-- Create the new table with original features instead of discretized scores
CREATE TABLE apsiii_req_features AS
WITH pa AS (
  SELECT bg.icustay_id,
         bg.charttime,
         po2 AS PaO2,
         ROW_NUMBER() OVER (PARTITION BY bg.icustay_id ORDER BY bg.po2 DESC) AS rn
    FROM blood_gas_first_day_arterial bg
         LEFT JOIN ventilation_durations vd
                ON bg.icustay_id = vd.icustay_id
               AND bg.charttime BETWEEN vd.starttime AND vd.endtime
   WHERE vd.icustay_id IS NULL -- patient is *not* ventilated
     AND COALESCE(fio2, fio2_chartevents, 21) < 50
     AND bg.po2 IS NOT NULL
),
aa AS (
  SELECT bg.icustay_id,
         bg.charttime,
         bg.aado2,
         ROW_NUMBER() OVER (PARTITION BY bg.icustay_id ORDER BY bg.aado2 DESC) AS rn
    FROM blood_gas_first_day_arterial bg
         INNER JOIN ventilation_durations vd
                 ON bg.icustay_id = vd.icustay_id
                AND bg.charttime BETWEEN vd.starttime AND vd.endtime
   WHERE vd.icustay_id IS NOT NULL -- patient is ventilated
     AND COALESCE(fio2, fio2_chartevents) >= 50
     AND bg.aado2 IS NOT NULL
),
acidbase AS (
  SELECT bg.icustay_id,
         ph,
         pco2 AS paco2,
         CASE
           WHEN ph IS NULL OR pco2 IS NULL THEN NULL
           WHEN ph < 7.20 THEN CASE WHEN pco2 < 50 THEN 12 ELSE 4 END
           WHEN ph < 7.30 THEN CASE
                                WHEN pco2 < 30 THEN 9
                                WHEN pco2 < 40 THEN 6
                                WHEN pco2 < 50 THEN 3
                                ELSE 2
                              END
           WHEN ph < 7.35 THEN CASE
                                WHEN pco2 < 30 THEN 9
                                WHEN pco2 < 45 THEN 0
                                ELSE 1
                              END
           WHEN ph < 7.45 THEN CASE
                                WHEN pco2 < 30 THEN 5
                                WHEN pco2 < 45 THEN 0
                                ELSE 1
                              END
           WHEN ph < 7.50 THEN CASE
                                WHEN pco2 < 30 THEN 5
                                WHEN pco2 < 35 THEN 0
                                WHEN pco2 < 45 THEN 2
                                ELSE 12
                              END
           WHEN ph < 7.60 THEN CASE WHEN pco2 < 40 THEN 3 ELSE 12 END
           ELSE CASE WHEN pco2 < 25 THEN 0 WHEN pco2 < 40 THEN 3 ELSE 12 END
         END AS acidbase_score
    FROM blood_gas_first_day_arterial bg
   WHERE ph IS NOT NULL AND pco2 IS NOT NULL
),
acidbase_max AS (
  SELECT icustay_id,
         acidbase_score,
         ph,
         paco2,
         ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY acidbase_score DESC) AS acidbase_rn
    FROM acidbase
),
arf AS (
  SELECT ie.icustay_id,
         CASE
           WHEN labs.creatinine_max >= 1.5
            AND uo.urineoutput < 410
            AND icd.ckd = 0 THEN 1
           ELSE 0
         END AS arf
    FROM icustays ie
         LEFT JOIN urine_output_first_day uo ON ie.icustay_id = uo.icustay_id
         LEFT JOIN labs_first_day labs ON ie.icustay_id = labs.icustay_id
         LEFT JOIN (
           SELECT hadm_id,
                  MAX(CASE
                        WHEN icd9_code IN ('5854', '5855', '5856') THEN 1
                        ELSE 0
                      END) AS ckd
             FROM diagnoses_icd
         GROUP BY hadm_id
         ) icd ON ie.hadm_id = icd.hadm_id
),
cohort AS (
  SELECT ie.subject_id,
         ie.hadm_id,
         ie.icustay_id,
         ie.intime,
         ie.outtime,
         vital.heartrate_min,
         vital.heartrate_max,
         vital.meanbp_min,
         vital.meanbp_max,
         vital.tempc_min,
         vital.tempc_max,
         vital.resprate_min,
         vital.resprate_max,
         pa.pao2,
         aa.aado2,
         ab.ph,
         ab.paco2,
         labs.hematocrit_min,
         labs.hematocrit_max,
         labs.wbc_min,
         labs.wbc_max,
         labs.creatinine_min,
         labs.creatinine_max,
         labs.bun_min,
         labs.bun_max,
         labs.sodium_min,
         labs.sodium_max,
         labs.albumin_min,
         labs.albumin_max,
         labs.bilirubin_min,
         labs.bilirubin_max,
         CASE
           WHEN labs.glucose_max IS NULL AND vital.glucose_max IS NULL THEN NULL
           WHEN labs.glucose_max IS NULL OR vital.glucose_max > labs.glucose_max THEN vital.glucose_max
           WHEN vital.glucose_max IS NULL OR labs.glucose_max > vital.glucose_max THEN labs.glucose_max
           ELSE labs.glucose_max
         END AS glucose_max,
         CASE
           WHEN labs.glucose_min IS NULL AND vital.glucose_min IS NULL THEN NULL
           WHEN labs.glucose_min IS NULL OR vital.glucose_min < labs.glucose_min THEN vital.glucose_min
           WHEN vital.glucose_min IS NULL OR labs.glucose_min < vital.glucose_min THEN labs.glucose_min
           ELSE labs.glucose_min
         END AS glucose_min,
         vent.vent,
         uo.urineoutput,
         gcs.mingcs,
         gcs.gcsmotor,
         gcs.gcsverbal,
         gcs.gcseyes,
         gcs.endotrachflag,
         arf.arf AS arf
    FROM icustays ie
         INNER JOIN admissions adm ON ie.hadm_id = adm.hadm_id
         INNER JOIN patients pat ON ie.subject_id = pat.subject_id
         LEFT JOIN pa ON ie.icustay_id = pa.icustay_id AND pa.rn = 1
         LEFT JOIN aa ON ie.icustay_id = aa.icustay_id AND aa.rn = 1
         LEFT JOIN acidbase_max ab ON ie.icustay_id = ab.icustay_id AND ab.acidbase_rn = 1
         LEFT JOIN arf ON ie.icustay_id = arf.icustay_id
         LEFT JOIN ventilation_first_day vent ON ie.icustay_id = vent.icustay_id
         LEFT JOIN gcs_first_day gcs ON ie.icustay_id = gcs.icustay_id
         LEFT JOIN vitals_first_day vital ON ie.icustay_id = vital.icustay_id
         LEFT JOIN urine_output_first_day uo ON ie.icustay_id = uo.icustay_id
         LEFT JOIN labs_first_day labs ON ie.icustay_id = labs.icustay_id
)
SELECT cohort.subject_id,
       cohort.hadm_id,
       cohort.icustay_id,
       cohort.heartrate_min,
       cohort.heartrate_max,
       cohort.meanbp_min,
       cohort.meanbp_max,
       cohort.tempc_min,
       cohort.tempc_max,
       cohort.resprate_min,
       cohort.resprate_max,
       cohort.pao2,
       cohort.aado2,
       cohort.ph,
       cohort.paco2,
       cohort.hematocrit_min,
       cohort.hematocrit_max,
       cohort.wbc_min,
       cohort.wbc_max,
       cohort.creatinine_min,
       cohort.creatinine_max,
       cohort.bun_min,
       cohort.bun_max,
       cohort.sodium_min,
       cohort.sodium_max,
       cohort.albumin_min,
       cohort.albumin_max,
       cohort.bilirubin_min,
       cohort.bilirubin_max,
       cohort.glucose_max,
       cohort.glucose_min,
       cohort.urineoutput,
       cohort.mingcs,
       cohort.gcsmotor,
       cohort.gcsverbal,
       cohort.gcseyes,
       cohort.endotrachflag
  FROM cohort
ORDER BY cohort.icustay_id;
