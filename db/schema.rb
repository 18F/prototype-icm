ActiveRecord::Schema[7.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "CRDMAIN", force: :cascade do |t|
    t.integer "BENEFITTED_POPULATION", null: true
    t.string "CASE_MATTER", limit: 1
    t.string "CASE_MATTER_SOURCE", limit: 20, null: true
    t.string "CASE_NAME", limit: 100, null: true
    t.string "CASE_STATUS", limit: 60, null: true
    t.date "CASE_STATUS_DT", null: true
    t.string "CITY", limit: 100, null: true
    t.date "CLOSED_DT", null: true
    t.date "CLOSE_DT", null: true
    t.string "CLOSE_UID", limit: 12, null: true
    t.string "COMPLIANCE_REVIEW", limit: 1, null: true
    t.integer "CONGREGATION_SIZE", null: true
    t.decimal "CRTAGE", limit: 22, null: true, precision: 23, scale: 0
    t.date "CRTDEC_FILEDT", null: true
    t.string "CRTJURIS_TYPE", limit: 20, null: true
    t.string "CRTNO_PERS_AFF", limit: 15, null: true
    t.decimal "CRTSORT_DIST", limit: 22, null: true, precision: 23, scale: 0
    t.string "CRTSORT_DISTLET", limit: 1, null: true
    t.string "CRT_ACTIVE_YN", limit: 1, null: true
    t.string "CRT_APP_NAME", limit: 100, null: true
    t.date "CRT_ATTNY_ASSGN", null: true
    t.string "CRT_ATTORNEY", limit: 12, null: true
    t.string "CRT_BILATERAL_NEGOTIATIONS", limit: 1, null: true
    t.date "CRT_CF_DATE", null: true
    t.string "CRT_COMPLETE", limit: 1, null: true
    t.date "CRT_CONT_LETTER_DATE", null: true
    t.string "CRT_COUNTY", limit: 25, null: true
    t.date "CRT_DATE_ASSIGNMENT", null: true
    t.date "CRT_DATE_REFERRED", null: true
    t.date "CRT_EDIT_DATE", null: true
    t.string "CRT_FAV_CT_APPEAL", limit: 1, null: true
    t.string "CRT_FAV_DEC", limit: 1, null: true
    t.string "CRT_FAV_MERITS", limit: 1, null: true
    t.string "CRT_FAV_SUPR_CT", limit: 1, null: true
    t.date "CRT_FINAL_ORDERS_DATE", null: true
    t.decimal "CRT_FISCAL_YEAR", limit: 22, null: true, precision: 4, scale: 0
    t.date "CRT_FRC_CLOSED_DATE", null: true
    t.string "CRT_FUND_SRC", limit: 1, null: true
    t.string "CRT_HISTORY", limit: 500, null: true
    t.string "CRT_INITIATIVE", limit: 20, null: true
    t.date "CRT_INVEST_AUTH_DATE", null: true
    t.string "CRT_INV_RESP", limit: 20, null: true
    t.string "CRT_NEXT_ACTION", limit: 500, null: true
    t.date "CRT_NOT_LET_DATE", null: true
    t.decimal "CRT_NO_DEFS_PER_FCASE", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "CRT_NO_EMPLOYEES", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "CRT_NO_FACILITIES", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "CRT_NO_JOBS", limit: 22, null: true, precision: 23, scale: 0
    t.string "CRT_NO_POT_VICTIMS", limit: 1, null: true
    t.decimal "CRT_NO_VICTIMS", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "CRT_NUMBER_SITES", limit: 22, null: true, precision: 23, scale: 0
    t.date "CRT_OPEN_DATE", null: true
    t.string "CRT_OPEN_UID", limit: 12, null: true
    t.string "CRT_PRIME_DJ", limit: 1, null: true
    t.string "CRT_REFER_ENTITY", limit: 20, null: true
    t.string "CRT_REFNUM", limit: 100, null: true
    t.date "CRT_SECT_CLOSED_DATE", null: true
    t.decimal "CRT_STUDENT_POPULAT", limit: 22, null: true, precision: 23, scale: 0
    t.date "CRT_SUIT_AUTH_DATE", null: true
    t.string "CRT_TRANSFER_APP", limit: 1, null: true
    t.date "CRT_TRANSFER_APP_DATE", null: true
    t.string "CRT_TYPE_C_M", limit: 1, null: true
    t.date "DEADLINE_DT", null: true
    t.string "DISTRICT", limit: 20, null: true
    t.string "DJ_NUMBER", limit: 25, null: true
    t.string "DOL_CASE_NUM", limit: 40, null: true
    t.string "DOL_RECOMM", limit: 1, null: true
    t.date "DT_INITIATED", null: true
    t.string "EDIT_UID", limit: 12, null: true
    t.date "ELECTION_DT", null: true
    t.date "ELIG_FORM_DATE", null: true
    t.date "ELS_DECLINE_DATE", null: true
    t.date "ENTRY_DT", null: true
    t.string "FAV_DISTRICT_COURT", limit: 1, null: true
    t.string "FAV_STATE_COURT", limit: 1, null: true
    t.string "FBI_NUMBER", limit: 20, null: true
    t.string "GOVT_ROLE", limit: 20, null: true
    t.string "LAW_ENFORCEMENT_AGENCY", limit: 100, null: true
    t.string "LIT_RESP", limit: 20, null: true
    t.string "LTLD_CODE", limit: 4, null: true
    t.decimal "MATTER_NO", limit: 22, precision: 23, scale: 0
    t.string "MEDIATION", limit: 1, null: true
    t.integer "NO_CONGREGATIONS", null: true
    t.integer "NO_COVERED_UNITS", null: true
    t.integer "NO_RENTAL_UNITS", null: true
    t.integer "NO_STATES", null: true
    t.string "OTRE_CODE", limit: 4, null: true
    t.decimal "POP_COUNTY", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "POP_DISCRIM_CLASS", limit: 22, null: true, precision: 23, scale: 0
    t.decimal "POT_DEFENDANTS_MATTER", limit: 22, null: true, precision: 23, scale: 0
    t.string "REF_TO_AGENCY", limit: 20, null: true
    t.date "REPR_GR_DATE", null: true
    t.string "REVIEWER", limit: 12, null: true
    t.string "SECTION", limit: 20, null: true
    t.integer "SEQUENCE", null: true
    t.string "SHARING_SEC", limit: 20, null: true
    t.string "SOLICITOR_OFF", limit: 20, null: true
    t.string "STATE", limit: 20, null: true
    t.string "STATUTE", limit: 20, null: true
    t.string "SYNOPSIS", limit: 4000, null: true
    t.string "ZIP", limit: 20, null: true
  end

end
