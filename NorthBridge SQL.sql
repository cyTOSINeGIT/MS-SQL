SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Tickets'
ORDER BY ORDINAL_POSITION;


--1) Confirm the Tickets row count
SELECT COUNT(*) AS ticket_count
FROM Tickets;

--2) Duplicate Check for TicketID - No duplicates

SELECT
    TicketID,
    COUNT(*) AS record_count
FROM Tickets
GROUP BY TicketID
HAVING COUNT(*) > 1;

--3) Missing key fields checks (Nulls check) - No Nulls

SELECT
    SUM(CASE WHEN TicketID IS NULL THEN 1 ELSE 0 END) AS missing_ticketid,
    SUM(CASE WHEN TicketReference IS NULL THEN 1 ELSE 0 END) AS missing_ticketreference,
    SUM(CASE WHEN ClientID IS NULL THEN 1 ELSE 0 END) AS missing_clientid,
    SUM(CASE WHEN PriorityID IS NULL THEN 1 ELSE 0 END) AS missing_priorityid,
    SUM(CASE WHEN CategoryID IS NULL THEN 1 ELSE 0 END) AS missing_categoryid,
    SUM(CASE WHEN AssignedAgentID IS NULL THEN 1 ELSE 0 END) AS missing_agentid,
    SUM(CASE WHEN SLADueAt IS NULL THEN 1 ELSE 0 END) AS missing_sladueat
FROM Tickets;


--4) Client table Null Check
    SELECT
    SUM(CASE WHEN ClientID IS NULL THEN 1 ELSE 0 END) AS missing_clientid,
    SUM(CASE WHEN ClientName IS NULL THEN 1 ELSE 0 END) AS missing_clientname,
    SUM(CASE WHEN ClientType IS NULL THEN 1 ELSE 0 END) AS missing_clienttype,
    SUM(CASE WHEN ContractTier IS NULL THEN 1 ELSE 0 END) AS missing_contracttier,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN ContractStartDate IS NULL THEN 1 ELSE 0 END) AS missing_contractstartdate,
    SUM(CASE WHEN ContractEndDate IS NULL THEN 1 ELSE 0 END) AS missing_contractenddate,
    SUM(CASE WHEN SLACreditClause IS NULL THEN 1 ELSE 0 END) AS missing_slacreditclause
FROM Clients;

---5) Client table Duplicate Check
SELECT
    ClientID,
    COUNT(*) AS record_count
FROM Clients
GROUP BY ClientID
HAVING COUNT(*) > 1;

--5) Null Check in Agents

SELECT
    SUM(CASE WHEN AgentID IS NULL THEN 1 ELSE 0 END) AS missing_agentid,
    SUM(CASE WHEN FullName IS NULL THEN 1 ELSE 0 END) AS missing_fullname,
    SUM(CASE WHEN TeamID IS NULL THEN 1 ELSE 0 END) AS missing_teamid,
    SUM(CASE WHEN Role IS NULL THEN 1 ELSE 0 END) AS missing_role,
    SUM(CASE WHEN Specialisms IS NULL THEN 1 ELSE 0 END) AS missing_specialisms,
    SUM(CASE WHEN Hub IS NULL THEN 1 ELSE 0 END) AS missing_hub,
    SUM(CASE WHEN DailyCapacity IS NULL THEN 1 ELSE 0 END) AS missing_dailycapacity
FROM Agents;

--6) Duplicate Check for Agents

    SELECT
    AgentID,
    COUNT(*) AS record_count
FROM Agents
GROUP BY AgentID
HAVING COUNT(*) > 1;

--7) SLA BREACH TOTALS CHECKS

SELECT
    SLABreached,
    COUNT(*) AS ticket_count
FROM Tickets
GROUP BY SLABreached
ORDER BY SLABreached;

--8) Calculated Overall SLA breaches

SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS breach_rate_pct
FROM Tickets;

--9) SLA breach by Priority

SELECT
    PriorityID,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY PriorityID
ORDER BY PriorityID;

--10) SLA BREACH BY CHANEL
SELECT
    Channel,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY Channel
ORDER BY breach_rate_pct DESC;

--11) SLA BREACH BY STATUS

SELECT
    Status,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY Status
ORDER BY breach_rate_pct DESC;

--12) Average Response Time

SELECT
    ROUND(
        AVG(CAST(DATEDIFF(MINUTE, CreatedAt, FirstResponseAt) AS DECIMAL(10,2))) / 60.0,
        2
    ) AS avg_response_hours
FROM Tickets
WHERE FirstResponseAt IS NOT NULL;

--13) Average Resolution Time

SELECT
    ROUND(
        AVG(CAST(DATEDIFF(MINUTE, CreatedAt, ResolvedAt) AS DECIMAL(10,2))) / 60.0,
        2
    ) AS avg_resolution_hours
FROM Tickets
WHERE ResolvedAt IS NOT NULL;

--14) Ticket Volume by Status

SELECT
    Status,
    COUNT(*) AS ticket_count,
    ROUND(
        100.0 * COUNT(*) /
        NULLIF((SELECT COUNT(*) FROM Tickets), 0),
        2
    ) AS percentage_of_total
FROM Tickets
GROUP BY Status
ORDER BY ticket_count DESC;


--15) Ticket Volume by Chanel

SELECT
    Channel,
    COUNT(*) AS ticket_count,
    ROUND(
        100.0 * COUNT(*) /
        NULLIF((SELECT COUNT(*) FROM Tickets), 0),
        2
    ) AS percentage_of_total
FROM Tickets
GROUP BY Channel
ORDER BY ticket_count DESC;


--16)  SLA Breach by Category

SELECT
    CategoryID,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY CategoryID
ORDER BY breach_rate_pct DESC;

--17) Average Response Time by Priority
SELECT
    PriorityID,
    ROUND(
        AVG(
            CAST(DATEDIFF(MINUTE, CreatedAt, FirstResponseAt) AS DECIMAL(10,2))
        ) / 60.0,
        2
    ) AS avg_response_hours
FROM Tickets
WHERE FirstResponseAt IS NOT NULL
GROUP BY PriorityID
ORDER BY PriorityID;

--18) Average Resolution Time by Priority

    SELECT
    PriorityID,
    ROUND(
        AVG(
            CAST(DATEDIFF(MINUTE, CreatedAt, ResolvedAt) AS DECIMAL(10,2))
        ) / 60.0,
        2
    ) AS avg_resolution_hours
FROM Tickets
WHERE ResolvedAt IS NOT NULL
GROUP BY PriorityID
ORDER BY PriorityID;

--19)  SLA BREACH BY CLIENT

    SELECT
    c.ClientName,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.ClientName
ORDER BY breach_rate_pct DESC;

--20) Ticket Volume by Client
SELECT
    c.ClientName,
    COUNT(*) AS ticket_count
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.ClientName
ORDER BY ticket_count DESC;

--21)  SLA BY CONTRACT TIER

        SELECT
    c.ContractTier,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.ContractTier
ORDER BY breach_rate_pct DESC;

--22) SLA BY CLIENT TYPE

    SELECT
    c.ClientType,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.ClientType
ORDER BY breach_rate_pct DESC;

--23) SLA BREACH BY REGION
SELECT
    c.Region,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.Region
ORDER BY breach_rate_pct DESC;


--24) Ticket Volume by Agent

SELECT
    a.AgentID,
    a.FullName,
    a.Role,
    a.Hub,
    COUNT(t.TicketID) AS ticket_count
FROM Tickets t
JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
GROUP BY
    a.AgentID,
    a.FullName,
    a.Role,
    a.Hub
ORDER BY ticket_count DESC;

--25) SLA BREACH RATE BY AGENT

SELECT
    a.AgentID,
    a.FullName,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
GROUP BY
    a.AgentID,
    a.FullName
ORDER BY breach_rate_pct DESC;

--26) Agent Work Load vs Daily Capacity

SELECT
    a.AgentID,
    a.FullName,
    a.DailyCapacity,
    COUNT(t.TicketID) AS ticket_count,
    ROUND(
        100.0 * COUNT(t.TicketID) / NULLIF(a.DailyCapacity, 0),
        2
    ) AS workload_pressure_pct
FROM Tickets t
JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
GROUP BY
    a.AgentID,
    a.FullName,
    a.DailyCapacity
ORDER BY workload_pressure_pct DESC;

--27) Agent workload and SLA breach

+
--28) Ticket Volume by Hub

SELECT
    a.Hub,
    COUNT(t.TicketID) AS ticket_count
FROM Tickets t
JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
GROUP BY a.Hub
ORDER BY ticket_count DESC;

--29) SLA BREACH RATE BY HUB

SELECT
    a.Hub,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
GROUP BY a.Hub
ORDER BY breach_rate_pct DESC;

--30) MONTLY TICKET VOLUME
SELECT
    YEAR(CreatedAt) AS ticket_year,
    MONTH(CreatedAt) AS ticket_month,
    COUNT(*) AS ticket_count
FROM Tickets
GROUP BY
    YEAR(CreatedAt),
    MONTH(CreatedAt)
ORDER BY
    ticket_year,
    ticket_month;

--31 A) MONTLY SLA BREACH RATE

SELECT
    YEAR(CreatedAt) AS ticket_year,
    MONTH(CreatedAt) AS ticket_month,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY
    YEAR(CreatedAt),
    MONTH(CreatedAt)
ORDER BY
    ticket_year,
    ticket_month;

--31 A) MONTLY SLA BREACH RATE
SELECT
    YEAR(CreatedAt) AS ticket_year,
    MONTH(CreatedAt) AS ticket_month,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY
    YEAR(CreatedAt),
    MONTH(CreatedAt)
ORDER BY
    breach_rate_pct DESC;

--32) Tickets and Status
    SELECT
    Status,
    COUNT(*) AS ticket_count
FROM Tickets
WHERE ResolvedAt IS NULL
GROUP BY Status
ORDER BY ticket_count DESC;

--33) ClIent with high ticket volume and breaches

SELECT
    c.ClientName,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.ClientName
HAVING COUNT(*) >= 50
ORDER BY breach_rate_pct DESC;

--34 SLA Breach by Client with Contract Credit Clause

SELECT
    c.SLACreditClause,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY c.SLACreditClause
ORDER BY breach_rate_pct DESC;

--35) Ticket without an Agent Match

SELECT
    COUNT(*) AS tickets_without_agent
FROM Tickets t
LEFT JOIN Agents a
    ON t.AssignedAgentID = a.AgentID
WHERE a.AgentID IS NULL;


---------------

---Views----


--1) Overall SLA KPIs

  CREATE VIEW vw_SLA_Overall AS
SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct,
    ROUND(
        AVG(
            CASE
                WHEN FirstResponseAt IS NOT NULL
                THEN CAST(DATEDIFF(MINUTE, CreatedAt, FirstResponseAt) AS DECIMAL(10,2))
            END
        ) / 60.0,
        2
    ) AS avg_response_hours,
    ROUND(
        AVG(
            CASE
                WHEN ResolvedAt IS NOT NULL
                THEN CAST(DATEDIFF(MINUTE, CreatedAt, ResolvedAt) AS DECIMAL(10,2))
            END
        ) / 60.0,
        2
    ) AS avg_resolution_hours
FROM Tickets;

   --2 Ticket SLA Detail

   CREATE VIEW vw_Ticket_SLA AS
SELECT
    TicketID,
    TicketReference,
    ClientID,
    AssignedAgentID,
    PriorityID,
    CategoryID,
    Channel,
    Status,
    CreatedAt,
    FirstResponseAt,
    ResolvedAt,
    SLADueAt,
    SLABreached,
    DATEDIFF(MINUTE, CreatedAt, FirstResponseAt) / 60.0 AS response_time_hours,
    DATEDIFF(MINUTE, CreatedAt, ResolvedAt) / 60.0 AS resolution_time_hours
FROM Tickets;

--3)

CREATE VIEW vw_Client_Performance AS
SELECT
    c.ClientID,
    c.ClientName,
    c.ClientType,
    c.ContractTier,
    c.Region,
    c.SLACreditClause,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Clients c
LEFT JOIN Tickets t
    ON c.ClientID = t.ClientID
GROUP BY
    c.ClientID,
    c.ClientName,
    c.ClientType,
    c.ContractTier,
    c.Region,
    c.SLACreditClause;

--4) Agent Performance

CREATE VIEW vw_Agent_Performance AS
SELECT
    a.AgentID,
    a.FullName,
    a.Role,
    a.Hub,
    a.DailyCapacity,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(t.TicketID), 0),
        2
    ) AS breach_rate_pct,
    ROUND(
        100.0 * COUNT(t.TicketID) / NULLIF(a.DailyCapacity, 0),
        2
    ) AS workload_pressure_pct
FROM Agents a
LEFT JOIN Tickets t
    ON a.AgentID = t.AssignedAgentID
GROUP BY
    a.AgentID,
    a.FullName,
    a.Role,
    a.Hub,
    a.DailyCapacity;


--5) Hub_Performance

CREATE VIEW vw_Hub_Performance AS
SELECT
    a.Hub,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Agents a
LEFT JOIN Tickets t
    ON a.AgentID = t.AssignedAgentID
GROUP BY a.Hub;

--6) Monthly SLA Trend

CREATE VIEW vw_Monthly_SLA AS
SELECT
    YEAR(CreatedAt) AS ticket_year,
    MONTH(CreatedAt) AS ticket_month,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets
GROUP BY
    YEAR(CreatedAt),
    MONTH(CreatedAt);

--7) High Risk Clients

CREATE VIEW vw_High_Risk_Clients AS
SELECT
    c.ClientID,
    c.ClientName,
    COUNT(t.TicketID) AS total_tickets,
    SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN t.SLABreached = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS breach_rate_pct
FROM Tickets t
JOIN Clients c
    ON t.ClientID = c.ClientID
GROUP BY
    c.ClientID,
    c.ClientName
HAVING COUNT(t.TicketID) >= 50;