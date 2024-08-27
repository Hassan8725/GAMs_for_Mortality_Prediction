\echo ''
\echo '==='
\echo 'Beginning to create materialized views for MIMIC database.'
\echo 'Any notices of the form  "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'
\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
\echo '==='
\echo ''

-- dependencies
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/demographics/icustay_times.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/demographics/icustay_hours.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/echo_data.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/code_status.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/rrt.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/weight_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/fluid_balance/urine_output.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/kdigo_uo.sql

-- durations
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/adenosine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/arterial_line_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/central_line_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/crrt_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/dobutamine_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/dobutamine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/dopamine_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/dopamine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/epinephrine_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/epinephrine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/isuprel_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/milrinone_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/neuroblock_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/norepinephrine_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/norepinephrine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/phenylephrine_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/phenylephrine_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/vasopressin_dose.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/vasopressin_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/vasopressor_durations.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/ventilation_classification.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/durations/ventilation_durations.sql

-- comorbidity
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/comorbidity/elixhauser_ahrq_v37.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/comorbidity/elixhauser_ahrq_v37_no_drg.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/comorbidity/elixhauser_quan.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/comorbidity/elixhauser_score_ahrq.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/comorbidity/elixhauser_score_quan.sql

-- demographics
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/demographics/heightweight.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/demographics/icustay_detail.sql

-- firstday
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/blood_gas_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/blood_gas_first_day_arterial.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/gcs_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/height_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/labs_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/rrt_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/urine_output_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/ventilation_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/vitals_first_day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/firstday/weight_first_day.sql

-- fluid_balance
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/fluid_balance/colloid_bolus.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/fluid_balance/crystalloid_bolus.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/fluid_balance/ffp_transfusion.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/fluid_balance/rbc_transfusion.sql

-- sepsis
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/sepsis/angus.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/sepsis/explicit.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/sepsis/martin.sql

-- diagnosis
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/diagnosis/ccs_dx.sql

-- organfailure
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/kdigo_creatinine.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/kdigo_stages.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/kdigo_stages_48hr.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/kdigo_stages_7day.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/organfailure/meld.sql

-- severityscores
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/apsiii.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/lods.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/mlods.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/oasis.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/qsofa.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/saps.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/sapsii.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/sirs.sql
\i C:/Users/hassa/mimic-code/mimic-iii/concepts_postgres/severityscores/sofa.sql

-- final tables which were dependent on one or more prior tables
