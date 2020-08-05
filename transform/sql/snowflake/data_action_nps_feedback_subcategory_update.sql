UPDATE analytics.mattermost.nps_feedback_classification
    SET nps_feedback_classification.subcategory = recent_updates.subcategory
    FROM (
        SELECT 
            last_feedback_date
          , user_id
          , server_id
          , feedback
          , field
          , new_value as subcategory
        FROM (
                SELECT 
                    ROW_NUMBER() OVER 
                        (PARTITION BY PARSE_JSON(other_params):last_feedback_date, PARSE_JSON(other_params):user_id, PARSE_JSON(other_params):server_id, PARSE_JSON(other_params):feedback, field ORDER BY triggered_at DESC) AS row_num
                  , PARSE_JSON(other_params):user_id::varchar AS user_id
                  , PARSE_JSON(other_params):server_id::varchar AS server_id
                  , PARSE_JSON(other_params):last_feedback_date::date AS last_feedback_date
                  , PARSE_JSON(other_params):feedback::varchar AS feedback
                  , field
                  , new_value
                FROM zapier_data_actions.data
                WHERE table_name = 'nps_feedback_classification' AND field IN ('subcategory') AND dwh_processed_at IS NULL
            )
        WHERE row_num = 1
        GROUP BY 1, 2, 3, 4, 5, 6
    ) AS recent_updates
    where nps_feedback_classification.last_feedback_date = recent_updates.last_feedback_date
        AND nps_feedback_classification.user_id = recent_updates.user_id
        AND nps_feedback_classification.server_id = recent_updates.server_id
        AND nps_feedback_classification.feedback = recent_updates.feedback;

UPDATE zapier_data_actions.data
SET dwh_processed_at = current_timestamp()
WHERE dwh_processed_at IS NULL AND table_name IN ('nps_feedback_classification') and field IN ('subcategory');