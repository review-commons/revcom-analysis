SELECT
    msOrig.cmpt_ms_nm AS 'manuscript_nm',
    msOrig.qc_complete_dt AS 'sub_date',
    CAST(msOrig.ms_title AS VARCHAR(128)) AS 'title',
    pAuth.last_nm AS 'corr_author',

    CASE
        WHEN (CAST(preprint.note AS VARCHAR(128)) IS NOT NULL) THEN 'Yes' 
        ELSE 'No'
    END AS 'preprint',

    CASE
        WHEN (msOrig.final_decision_ind = 2) THEN 'suggest posting of reviews'
        WHEN (msOrig.final_decision_ind = 4) THEN 'rejected before review'
        ELSE 'Undefined decision' + CONVERT(NVARCHAR, msOrig.final_decision_ind)
    END AS rev_com_decision,

    STRING_AGG(
        CASE
            WHEN rct.dest_j_id=415 THEN 'elife'
            WHEN rct.dest_j_id=450 THEN 'emboj'
            WHEN rct.dest_j_id=40 THEN 'mboc'
            WHEN rct.dest_j_id=451 THEN 'er'
            WHEN rct.dest_j_id=216 THEN 'emm'
            WHEN rct.dest_j_id=496 THEN 'jcb'
            WHEN rct.dest_j_id=702 THEN 'lsa'
            WHEN rct.dest_j_id=452 THEN 'msb'
            WHEN rct.dest_j_id=1000001 THEN 'jcs'
            WHEN rct.dest_j_id=1000002 THEN 'plosone'
            WHEN rct.dest_j_id=1000003 THEN 'plosbio'
            WHEN rct.dest_j_id=1000004 THEN 'biolopen'
            WHEN rct.dest_j_id=1000005 THEN 'dev'
            WHEN rct.dest_j_id=1000006 THEN 'dmm'
            WHEN rct.dest_j_id=1000007 THEN 'plosgen'
            WHEN rct.dest_j_id=1000008 THEN 'plospath'
            WHEN rct.dest_j_id=1000009 THEN 'ploscomp'
            ELSE 'Unknown j-id: '+CONVERT(varchar, rct.dest_j_id)
        END,
        ', '
    ) AS 'journal',

    STRING_AGG(
        CASE
            WHEN rct.response_ind=1 THEN 'init_transfer'
            WHEN rct.response_ind=5 THEN 'more_time'
            WHEN rct.response_ind=2 THEN 'consider'
            WHEN rct.response_ind=3 THEN 'reject'
            WHEN rct.response_ind=4 THEN 'no_response'
            ELSE 'Unknown response-ind: '+CONVERT(varchar, rct.response_ind)
        END,
        ', '
     ) AS 'transfer_response',

    COUNT(rct.response_ind) AS 'num_transfers',

    STRING_AGG(
        CASE
            WHEN rct.dest_j_dec_ind=1 THEN 'accept'
            WHEN rct.dest_j_dec_ind=4 THEN 'reject'
            WHEN rct.dest_j_dec_ind=6 THEN 'withdrawn'
            ELSE 'Unknown dest-j-dec-ind: '+CONVERT(varchar, rct.dest_j_dec_ind)
        END,
        ', '
    ) AS 'journal_decision'

FROM
    Manuscript ms LEFT JOIN RCTransfer rct ON (
        ms.j_id = rct.j_id
        AND ms.ms_id = rct.ms_id
        AND ms.ms_rev_no = rct.ms_rev_no
    ),
    Person pAuth,
    Manuscript msOrig
    LEFT JOIN Notes preprint ON (
        msOrig.j_id = preprint.j_id
        AND msOrig.ms_id = preprint.ms_id
        AND msOrig.ms_rev_no = preprint.ms_rev_no
        AND (
            (
                preprint.note_type_ind=974
                AND (
                    preprint.note LIKE 'biorxiv' 
                    OR preprint.note LIKE 'medrxiv'
                )
            )
            OR (
                preprint.note_type_ind=953
                AND preprint.note LIKE '%"enabled":"1"%'
            )
        )
    )

WHERE
    ms.j_id = 790
    AND ms.current_stage_id NOT IN (840, 850)
    AND msOrig.j_id = ms.j_id
    AND msOrig.ms_id = ms.ms_id
    AND msOrig.ms_rev_no = 0
    AND msOrig.corresponding_p_id = pAuth.p_id
    AND msOrig.qc_complete_dt BETWEEN '2019-01-01' AND '2021-03-31'

GROUP BY
    msOrig.cmpt_ms_nm,
    msOrig.qc_complete_dt,
    msOrig.final_decision_ind,
    CAST(msOrig.ms_title AS VARCHAR(128)),
    pAuth.last_nm,
    CAST(preprint.note AS VARCHAR(128))

ORDER BY
    msOrig.cmpt_ms_nm