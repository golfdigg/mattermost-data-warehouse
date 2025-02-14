select
    daily_server_id,
    server_id,
    snapshot_date,
    version_full,
    version_major,
    version_minor,
    version_patch,
    operating_system,
    database_type,
    database_version,
    is_enterprise_ready,
    installation_id,
    is_cloud,
    server_ip,
    installation_type,
    count_reported_versions
from
    {{ ref('int_server_info_daily_snapshot') }}