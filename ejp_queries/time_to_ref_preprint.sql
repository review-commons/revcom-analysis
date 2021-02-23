SELECT
    sub.cmpt_ms_nm AS manuscript_nm,
    rev.ms_rev_no AS rev_no,
    sub.ms_title AS title,
    -- CAST(pbp.note AS VARCHAR(1024)) AS note, -- truncated text of the reply
    sub.qc_complete_dt AS sub_date,
    pbp.create_dt AS posting_date,
    DATEDIFF(day, sub.qc_complete_dt, pbp.create_dt) AS time_to_ref_preprint,
    link.note AS url,
    doi.note AS doi


FROM 
    Journal AS jou
    JOIN Manuscript sub ON sub.j_id = jou.j_id AND sub.ms_rev_no = 0
    JOIN Manuscript rev On rev.j_id = jou.j_id AND rev.ms_rev_no > 0
    JOIN Notes pbp ON
        pbp.j_id = jou.j_id AND pbp.ms_id = sub.ms_id AND pbp.ms_rev_no = rev.ms_rev_no
        AND  pbp.note_type_ind = 937. -- point by point
    LEFT JOIN Notes link ON
        link.j_id = jou.j_id AND link.ms_id = sub.ms_id AND link.ms_rev_no = rev.ms_rev_no
        AND link.note_type_ind = 951  -- preprint url
    LEFT JOIN Notes doi ON
        doi.j_id = jou.j_id AND doi.ms_id = sub.ms_id AND doi.ms_rev_no = rev.ms_rev_no
        AND doi.note_type_ind = 939  -- preprint doi

WHERE
    jou.j_abbrev = 'reviewcommons'
    AND sub.ms_id = rev.ms_id
    AND sub.current_stage_id NOT IN (840, 850)  -- not halted or withdrawn
    AND rev.current_stage_id NOT IN (840, 850)  -- not halted or withdrawn
    AND sub.ms_title NOT LIKE '%test %'

ORDER BY
    sub.cmpt_ms_nm
