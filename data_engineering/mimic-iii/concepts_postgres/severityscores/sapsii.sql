-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS sapsii; CREATE TABLE sapsii AS
-- ------------------------------------------------------------------
-- Title: Simplified Acute Physiology Score II (SAPS II)
-- This query extracts the simplified acute physiology score II.
-- This score is a measure of patient severity of illness.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for SAPS II:
--    Le Gall, Jean-Roger, Stanley Lemeshow, and Fabienne Saulnier.
--    "A new simplified acute physiology score (SAPS II) based on a European/North American multicenter study."
--    JAMA 270, no. 24 (1993): 2957-2963.

-- Variables used in SAPS II:
--  Age, GCS
--  VITALS: Heart rate, systolic blood pressure, temperature
--  FLAGS: ventilation/cpap
--  IO: urine output
--  LABS: PaO2/FiO2 ratio, blood urea nitrogen, WBC, potassium, sodium, HCO3

-- The following views are required to run this query:
--  1) urine_output_first_day - generated by urine-output-first-day.sql
--  2) ventilation_durations - generated by ventilation_durations.sql
--  3) vitals_first_day - generated by vitals-first-day.sql
--  4) gcs_first_day - generated by gcs-first-day.sql
--  5) labs_first_day - generated by labs-first-day.sql
--  6) blood_gas_arterial_first_day - generated by blood-gas-first-day-arterial.sql

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate ICUSTAY_IDs.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.

-- extract CPAP from the "Oxygen Delivery Device" fields
with cpap as
(
  select ie.icustay_id
    , min(DATETIME_SUB(charttime, INTERVAL '1' HOUR)) as starttime
    , max(DATETIME_ADD(charttime, INTERVAL '4' HOUR)) as endtime
    , max(CASE
          WHEN lower(ce.value) LIKE '%cpap%' THEN 1
          WHEN lower(ce.value) LIKE '%bipap mask%' THEN 1
        else 0 end) as cpap
  FROM icustays ie
  inner join chartevents ce
    on ie.icustay_id = ce.icustay_id
    and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  where itemid in
  (
    -- TODO: when metavision data import fixed, check the values in 226732 match the value clause below
    467, 469, 226732
  )
  and (lower(ce.value) LIKE '%cpap%' or lower(ce.value) LIKE '%bipap mask%')
  -- exclude rows marked as error
  AND (ce.error IS NULL OR ce.error = 0)
  group by ie.icustay_id
)
-- extract a flag for surgical service
-- this combined with "elective" FROM admissions table defines elective/non-elective surgery
, surgflag as
(
  select adm.hadm_id
    , case when lower(curr_service) like '%surg%' then 1 else 0 end as surgical
    , ROW_NUMBER() over
    (
      PARTITION BY adm.HADM_ID
      ORDER BY TRANSFERTIME
    ) as serviceOrder
  FROM admissions adm
  left join services se
    on adm.hadm_id = se.hadm_id
)
-- icd-9 diagnostic codes are our best source for comorbidity information
-- unfortunately, they are technically a-causal
-- however, this shouldn't matter too much for the SAPS II comorbidities
, comorb as
(
select hadm_id
-- these are slightly different than elixhauser comorbidities, but based on them
-- they include some non-comorbid ICD-9 codes (e.g. 20302, relapse of multiple myeloma)
  , max(CASE
    when SUBSTR(icd9_code,1,3) BETWEEN '042' AND '044' THEN 1
  		end) as aids      /* HIV and AIDS */
  , max(CASE
    when icd9_code between '20000' and '20238' then 1 -- lymphoma
    when icd9_code between '20240' and '20248' then 1 -- leukemia
    when icd9_code between '20250' and '20302' then 1 -- lymphoma
    when icd9_code between '20310' and '20312' then 1 -- leukemia
    when icd9_code between '20302' and '20382' then 1 -- lymphoma
    when icd9_code between '20400' and '20522' then 1 -- chronic leukemia
    when icd9_code between '20580' and '20702' then 1 -- other myeloid leukemia
    when icd9_code between '20720' and '20892' then 1 -- other myeloid leukemia
    when SUBSTR(icd9_code,1,4) = '2386' then 1 -- lymphoma
    when SUBSTR(icd9_code,1,4) = '2733' then 1 -- lymphoma
  		end) as hem
  , max(CASE
    when SUBSTR(icd9_code,1,4) BETWEEN '1960' AND '1991' THEN 1
    when icd9_code between '20970' and '20975' then 1
    when icd9_code = '20979' then 1
    when icd9_code = '78951' then 1
  		end) as mets      /* Metastatic cancer */
  from diagnoses_icd
  group by hadm_id
)
, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  -- also join to cpap table for the same purpose
  select bg.icustay_id, bg.charttime
  , pao2fio2
  , case when vd.icustay_id is not null then 1 else 0 end as vent
  , case when cp.icustay_id is not null then 1 else 0 end as cpap
  from blood_gas_first_day_arterial bg
  left join ventilation_durations vd
    on bg.icustay_id = vd.icustay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
  left join cpap cp
    on bg.icustay_id = cp.icustay_id
    and bg.charttime >= cp.starttime
    and bg.charttime <= cp.endtime
)
, pafi2 as
(
  -- get the minimum PaO2/FiO2 ratio *only for ventilated/cpap patients*
  select icustay_id
  , min(pao2fio2) as pao2fio2_vent_min
  from pafi1
  where vent = 1 or cpap = 1
  group by icustay_id
)
, cohort as
(
select ie.subject_id, ie.hadm_id, ie.icustay_id
      , ie.intime
      , ie.outtime

      -- the casts ensure the result is numeric.. we could equally extract EPOCH from the interval
      -- however this code works in Oracle and Postgres
      , DATETIME_DIFF(ie.intime, pat.dob, 'YEAR') as age

      , vital.heartrate_max
      , vital.heartrate_min
      , vital.sysbp_max
      , vital.sysbp_min
      , vital.tempc_max
      , vital.tempc_min

      -- this value is non-null iff the patient is on vent/cpap
      , pf.pao2fio2_vent_min

      , uo.urineoutput

      , labs.bun_min
      , labs.bun_max
      , labs.wbc_min
      , labs.wbc_max
      , labs.potassium_min
      , labs.potassium_max
      , labs.sodium_min
      , labs.sodium_max
      , labs.bicarbonate_min
      , labs.bicarbonate_max
      , labs.bilirubin_min
      , labs.bilirubin_max

      , gcs.mingcs

      , comorb.aids
      , comorb.hem
      , comorb.mets

      , case
          when adm.ADMISSION_TYPE = 'ELECTIVE' and sf.surgical = 1
            then 'ScheduledSurgical'
          when adm.ADMISSION_TYPE != 'ELECTIVE' and sf.surgical = 1
            then 'UnscheduledSurgical'
          else 'Medical'
        end as admissiontype


FROM icustays ie
inner join admissions adm
  on ie.hadm_id = adm.hadm_id
inner join patients pat
  on ie.subject_id = pat.subject_id

-- join to above views
left join pafi2 pf
  on ie.icustay_id = pf.icustay_id
left join surgflag sf
  on adm.hadm_id = sf.hadm_id and sf.serviceOrder = 1
left join comorb
  on ie.hadm_id = comorb.hadm_id

-- join to custom tables to get more data....
left join gcs_first_day gcs
  on ie.icustay_id = gcs.icustay_id
left join vitals_first_day vital
  on ie.icustay_id = vital.icustay_id
left join urine_output_first_day uo
  on ie.icustay_id = uo.icustay_id
left join labs_first_day labs
  on ie.icustay_id = labs.icustay_id
)
, scorecomp as
(
select
  cohort.*
  -- Below code calculates the component scores needed for SAPS
  , case
      when age is null then null
      when age <  40 then 0
      when age <  60 then 7
      when age <  70 then 12
      when age <  75 then 15
      when age <  80 then 16
      when age >= 80 then 18
    end as age_score

  , case
      when heartrate_max is null then null
      when heartrate_min <   40 then 11
      when heartrate_max >= 160 then 7
      when heartrate_max >= 120 then 4
      when heartrate_min  <  70 then 2
      when  heartrate_max >= 70 and heartrate_max < 120
        and heartrate_min >= 70 and heartrate_min < 120
      then 0
    end as hr_score

  , case
      when  sysbp_min is null then null
      when  sysbp_min <   70 then 13
      when  sysbp_min <  100 then 5
      when  sysbp_max >= 200 then 2
      when  sysbp_max >= 100 and sysbp_max < 200
        and sysbp_min >= 100 and sysbp_min < 200
        then 0
    end as sysbp_score

  , case
      when tempc_max is null then null
      when tempc_min <  39.0 then 0
      when tempc_max >= 39.0 then 3
    end as temp_score

  , case
      when pao2fio2_vent_min is null then null
      when pao2fio2_vent_min <  100 then 11
      when pao2fio2_vent_min <  200 then 9
      when pao2fio2_vent_min >= 200 then 6
    end as pao2fio2_score

  , case
      when urineoutput is null then null
      when urineoutput <   500.0 then 11
      when urineoutput <  1000.0 then 4
      when urineoutput >= 1000.0 then 0
    end as uo_score

  , case
      when bun_max is null then null
      when bun_max <  28.0 then 0
      when bun_max <  84.0 then 6
      when bun_max >= 84.0 then 10
    end as bun_score

  , case
      when wbc_max is null then null
      when wbc_min <   1.0 then 12
      when wbc_max >= 20.0 then 3
      when wbc_max >=  1.0 and wbc_max < 20.0
       and wbc_min >=  1.0 and wbc_min < 20.0
        then 0
    end as wbc_score

  , case
      when potassium_max is null then null
      when potassium_min <  3.0 then 3
      when potassium_max >= 5.0 then 3
      when potassium_max >= 3.0 and potassium_max < 5.0
       and potassium_min >= 3.0 and potassium_min < 5.0
        then 0
      end as potassium_score

  , case
      when sodium_max is null then null
      when sodium_min  < 125 then 5
      when sodium_max >= 145 then 1
      when sodium_max >= 125 and sodium_max < 145
       and sodium_min >= 125 and sodium_min < 145
        then 0
      end as sodium_score

  , case
      when bicarbonate_max is null then null
      when bicarbonate_min <  15.0 then 5
      when bicarbonate_min <  20.0 then 3
      when bicarbonate_max >= 20.0
       and bicarbonate_min >= 20.0
          then 0
      end as bicarbonate_score

  , case
      when bilirubin_max is null then null
      when bilirubin_max  < 4.0 then 0
      when bilirubin_max  < 6.0 then 4
      when bilirubin_max >= 6.0 then 9
      end as bilirubin_score

   , case
      when mingcs is null then null
        when mingcs <  3 then null -- erroneous value/on trach
        when mingcs <  6 then 26
        when mingcs <  9 then 13
        when mingcs < 11 then 7
        when mingcs < 14 then 5
        when mingcs >= 14
         and mingcs <= 15
          then 0
        end as gcs_score

    , case
        when aids = 1 then 17
        when hem  = 1 then 10
        when mets = 1 then 9
        else 0
      end as comorbidity_score

    , case
        when admissiontype = 'ScheduledSurgical' then 0
        when admissiontype = 'Medical' then 6
        when admissiontype = 'UnscheduledSurgical' then 8
        else null
      end as admissiontype_score

from cohort
)
-- Calculate SAPS II here so we can use it in the probability calculation below
, score as
(
  select s.*
  -- coalesce statements impute normal score of zero if data element is missing
  , coalesce(age_score,0)
  + coalesce(hr_score,0)
  + coalesce(sysbp_score,0)
  + coalesce(temp_score,0)
  + coalesce(pao2fio2_score,0)
  + coalesce(uo_score,0)
  + coalesce(bun_score,0)
  + coalesce(wbc_score,0)
  + coalesce(potassium_score,0)
  + coalesce(sodium_score,0)
  + coalesce(bicarbonate_score,0)
  + coalesce(bilirubin_score,0)
  + coalesce(gcs_score,0)
  + coalesce(comorbidity_score,0)
  + coalesce(admissiontype_score,0)
    as sapsii
  from scorecomp s
)
select ie.subject_id, ie.hadm_id, ie.icustay_id
, sapsii
, 1 / (1 + exp(- (-7.7631 + 0.0737*(sapsii) + 0.9971*(ln(sapsii + 1))) )) as sapsii_prob
, age_score
, hr_score
, sysbp_score
, temp_score
, pao2fio2_score
, uo_score
, bun_score
, wbc_score
, potassium_score
, sodium_score
, bicarbonate_score
, bilirubin_score
, gcs_score
, comorbidity_score
, admissiontype_score
FROM icustays ie
left join score s
  on ie.icustay_id = s.icustay_id
order by ie.icustay_id;
