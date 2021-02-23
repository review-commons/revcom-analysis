SELECT DISTINCT

-- Provides the length of referee reports and time to secure reviewers on a per paper basis
-- Data across all journals. 
-- Transferred Review Commons excluded since they are already reviewed.
-- Only research articles, reports, resources and methods are included.

    jou.j_abbrev AS journal,
    m.cmpt_ms_nm AS manuscript_nm,
    COUNT(DISTINCT r.p_id) AS num_reports,
    SUM(DATALENGTH(refrep.note)) / COUNT(DISTINCT r.p_id) AS review_len,
    AVG(CAST(DATEDIFF(day, m.qc_complete_dt, r.rev_start_dt) AS float)) AS avg_time_to_secure_rev,
    MIN(CAST(DATEDIFF(day, m.qc_complete_dt, r.rev_start_dt) AS float)) AS min_time_to_secure_rev,
    AVG(CAST(r.rev_duration AS float)) AS review_duration

FROM
    Manuscript m
    JOIN Journal jou ON jou.j_id = m.j_id
    JOIN Notes refrep ON refrep.j_id = jou.j_id AND refrep.ms_id = m.ms_id AND refrep.ms_rev_no = m.ms_rev_no
    LEFT JOIN Notes trsfr ON trsfr.j_id = jou.j_id AND trsfr.ms_id = m.ms_id AND trsfr.ms_rev_no = m.ms_rev_no AND trsfr.note_type_ind = 906 -- indicates a transfer
    JOIN Reviewer r ON r.p_id = refrep.p_id AND r.j_id = m.j_id AND r.ms_id = m.ms_id AND r.ms_rev_no = m.ms_rev_no

WHERE
    m.ms_rev_no = 0 -- only initial submission, no revision
    AND m.qc_complete_dt BETwEEN '2019-12-01' AND '2021-03-01' -- since Rev Com launch
    AND
    (
        (jou.j_abbrev = 'emboj' AND m.ms_type_cde IN (1, 19))  -- articles, resources
        OR
        (jou.j_abbrev = 'embor' AND m.ms_type_cde IN (1, 29, 36))  -- articles, reports, resources
        OR
        (jou.j_abbrev = 'msb' AND m.ms_type_cde IN (1, 2, 19))  -- articles, reports, method
        OR
        (jou.j_abbrev = 'embomolmed' AND m.ms_type_cde IN (10, 13, 28))  -- articles, reports
        OR
        (jou.j_abbrev = 'reviewcommons' AND m.ms_type_cde = 1)  -- articles
    )
    AND
    (
        (refrep.note_type_ind = 10004 AND jou.j_abbrev = 'emboj')  -- 10004 is ref rep in emboj 
        OR
        (refrep.note_type_ind = 39 AND jou.j_abbrev IN ('embor', 'msb'))  -- 39 is ref report in msb and embor
        OR
        (refrep.note_type_ind in (1610, 1616) AND jou.j_abbrev = 'embomolmed')  -- 1610 Comments on Novelty 1616 is remarks for authors
        OR
        (refrep.note_type_ind IN (10097, 10098) AND jou.j_abbrev = 'reviewcommons')  -- 10098 for validity and 10097 for significance 281 would be concatenated reports
    )
    AND
    (
        (NOT CAST(trsfr.note AS VARCHAR(16)) = 'review commons')  -- exclude transfer of already reviewed papers
        OR trsfr.note IS NULL  -- most are not transfer and LEFT JOIN will leave column null
    )


GROUP BY
    m.cmpt_ms_nm,
    jou.j_abbrev