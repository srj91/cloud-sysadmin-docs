SELECT 
    datname AS database_name,
    pg_size_pretty(pg_database_size(datname)) AS database_size
FROM 
    pg_database
WHERE 
    has_database_privilege(datname, 'CONNECT');
