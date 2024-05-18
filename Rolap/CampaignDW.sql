CREATE DATABASE CampaignDW
GO
ALTER DATABASE CampaignDW
SET RECOVERY SIMPLE
GO

USE CampaignDW
;






-- Create a schema to hold user views (set schema name on home page of workbook).
-- It would be good to do this only if the schema doesn't exist already.
GO
CREATE SCHEMA campaign
GO






/* Drop table campaign.DimCategory */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimCategory') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimCategory 
;

/* Create table campaign.DimCategory */
CREATE TABLE campaign.DimCategory (
   [category_id]  nchar(25)   NOT NULL
,  [category_name]  nvarchar(255)   NOT NULL
, CONSTRAINT [PK_campaign.DimCategory] PRIMARY KEY CLUSTERED 
( [category_id] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT campaign.DimCategory ON
;
INSERT INTO campaign.DimCategory (category_id, category_name)
VALUES ('1', 'No Category')
;
SET IDENTITY_INSERT campaign.DimCategory OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Category]'))
DROP VIEW [campaign].[Category]
GO
CREATE VIEW [campaign].[Category] AS 
SELECT [category_id] AS [category_id]
, [category_name] AS [category_name]
FROM campaign.DimCategory
GO




/* Drop table campaign.DimLocation */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimLocation') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimLocation 
;

/* Create table campaign.DimLocation */
CREATE TABLE campaign.DimLocation (
   [location_id]  nvarchar(25)   NOT NULL
,  [location_name]  nvarchar(255)   NOT NULL
,  [location_country]  nvarchar(255)  NULL
, CONSTRAINT [PK_campaign.DimLocation] PRIMARY KEY CLUSTERED 
( [location_id] )
) ON [PRIMARY]
;


INSERT INTO campaign.DimLocation (location_id, location_name, location_country)
VALUES ('-1', 'No Name', 'No Country')
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Location]'))
DROP VIEW [campaign].[Location]
GO
CREATE VIEW [campaign].[Location] AS 
SELECT [location_id] AS [location_id]
, [location_name] AS [location_name]
, [location_country] AS [location_country] 
FROM campaign.DimLocation
GO



/* Drop table campaign.DimProject */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimProject') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimProject 
;

/* Create table campaign.DimProject */
CREATE TABLE campaign.DimProject (
   [project_id]  nchar(25)   NOT NULL
,  [project_name]  nvarchar(255)   NOT NULL
,  [project_state]  nvarchar(255)  NOT NULL
, CONSTRAINT [PK_campaign.DimProject] PRIMARY KEY CLUSTERED 
( [project_id] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT campaign.DimProject ON
;
INSERT INTO campaign.DimProject (project_id, project_name, project_state)
VALUES ('-1', 'None', 'None')
;
SET IDENTITY_INSERT campaign.DimProject OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Project]'))
DROP VIEW [campaign].[Project]
GO
CREATE VIEW [campaign].[Project] AS 
SELECT [project_id] AS [project_id]
, [project_name] AS [project_name]
, [project_state] AS [project_state]
FROM campaign.DimProject
GO






/* Drop table campaign.DimDate */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimDate') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimDate 
;

/* Create table campaign.DimDate */
CREATE TABLE campaign.DimDate (
   [date_id]  int IDENTITY  NOT NULL
,  [project_created_at]  datetime  NOT NULL
,  [project_launched_at]  datetime  NOT NULL
,  [deadline]  datetime  NOT NULL
,  [project_state_changed_at]  datetime  NOT NULL
, CONSTRAINT [PK_campaign.DimDate] PRIMARY KEY CLUSTERED 
( [date_id] )
) ON [PRIMARY]
;



SET IDENTITY_INSERT campaign.DimDate ON
;
INSERT INTO campaign.DimDate (date_id, project_created_at, deadline, project_launched_at, project_state_changed_at)
VALUES (-1, '2022-08-27', '2022-08-27', '2022-08-27', '2022-12-14')
;
SET IDENTITY_INSERT campaign.DimDate OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Date]'))
DROP VIEW [campaign].[Date]
GO
CREATE VIEW [campaign].[Date] AS 
SELECT [date_id] AS [d_id]
, [project_created_at] AS [project_created_at]
, [project_launched_at] AS [project_launched_at]
, [deadline] AS [deadline] 
, [project_state_changed_at] AS [project_state_changed_at]
FROM campaign.DimDate
GO







/* Drop table campaign.BackerFact */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.BackerFact') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.BackerFact 
;

/* Create table campaign.BackerFact */
CREATE TABLE campaign.BackerFact (
   [category_id]  nchar(25)   NOT NULL
,  [location_id]  nvarchar(25)   NOT NULL
,  [project_id]  nchar(25)   NOT NULL
,  [date_id]  int   NOT NULL
,  [backers_count]  int   NOT NULL
,  [amount_pledged]  int   NOT NULL
,  [goal] int NOT NULL
CONSTRAINT CompositeKey PRIMARY KEY ([category_id], [location_id], [project_id], [date_id])
);

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[BackerFact]'))
DROP VIEW [campaign].[BackerFactView]
GO

CREATE VIEW [campaign].[BackerFactView] AS 
SELECT [category_id] AS [category_id]
, [location_id] AS [location_id]
, [project_id] AS [project_id]
, [date_id] AS [date_id]
, [backers_count] AS [backers_count]
, [amount_pledged] AS [amount_pledged]
, [goal] AS [goal]
FROM campaign.BackerFact
GO

ALTER TABLE campaign.BackerFact ADD CONSTRAINT
   FK_campaign_BackerFact_category_id FOREIGN KEY
   (
   category_id
   ) REFERENCES campaign.DimCategory
   ( category_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE campaign.BackerFact ADD CONSTRAINT
   FK_campaign_BackerFact_location_id FOREIGN KEY
   (
   location_id
   ) REFERENCES campaign.DimLocation
   ( location_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE campaign.BackerFact ADD CONSTRAINT
   FK_campaign_BackerFact_p_id FOREIGN KEY
   (
   project_id
   ) REFERENCES campaign.DimProject
   ( project_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE campaign.BackerFact ADD CONSTRAINT
   FK_campaign_BackerFact_date_id FOREIGN KEY
   (
   date_id
   ) REFERENCES campaign.DimDate
   ( date_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;