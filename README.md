# SaaS Revenue Analytics

## Project Overview

SaaS Revenue Analytics is an end-to-end Analytics Engineering project built around CRM and billing data from HubSpot and Subskribe.

The project transforms raw operational data into reliable, analytics-ready datasets for analyzing customers, subscriptions, invoices, and SaaS revenue.

The project is designed as a modern analytics workflow covering data ingestion, transformation and
modeling with BigQuery and dbt, data quality testing, environment separation,
automated CI/CD pipelines, business intelligence with Power BI, and workflow
orchestration with Airflow.

The project also explores containerization with Docker and Infrastructure as Code with Terraform to build a more reproducible and production-oriented analytics platform.


## Project Roadmap

- [x] Data ingestion and BigQuery setup
- [x] dbt staging, intermediate and marts
- [x] Data quality testing
- [x] DEV / CI / PROD environment separation
- [x] CI pipeline
- [x] CD pipeline
- [x] Power BI - Executive Overview
- [ ] Power BI - Revenue & Customer Retention
- [ ] Power BI - Customer Analysis
- [ ] Airflow orchestration
- [ ] Docker containerization
- [ ] Terraform infrastructure


## Architecture

The project follows a layered analytics architecture with separate development, CI, and production environments.

```text
                         HubSpot / Subskribe
                                 │
                                 ▼
                        ┌─────────────────┐
                        │  BigQuery RAW   │
                        │       raw       │
                        └────────┬────────┘
                                 │
                                 ▼
                                dbt
                                 │
              ┌──────────────────┼─────────────────────┐
              │                  │                     │
              ▼                  ▼                     ▼
         DEVELOPMENT             CI                PRODUCTION
          dbt_karim            dbt_ci                  │
              │                  │                     │
      stg / int / marts   stg / int / marts     ┌──────┴──────┐
                                                │             │
                                                ▼             ▼
                                      dbt_prod_technical   analytics
                                            stg / int        marts
                                                              │
                                                              ▼
                                                           Power BI
```


## Data Source & Credits

This project is based on the public Tracksuit Data Engineer Analytics take-home task.

The original business case and sample HubSpot and Subskribe datasets were provided by Tracksuit.

Original source: [Tracksuit Data Engineer Analytics Take-Home Task](https://github.com/gotracksuit/tracksuit-data-engineer-analytics-take-home-task-public)

The project was independently extended into a complete Analytics Engineering workflow, including data architecture, dbt modeling, data quality testing, environment separation, and automated CI/CD.


## Data Modeling

### Source Data Exploration

Before building the dbt models, the raw HubSpot and Subskribe datasets were extensively explored in BigQuery to understand their structure, relationships, and business rules.

The analysis focused on four main areas:

- **Key validation:** uniqueness and completeness of company, account, subscription, and invoice identifiers.
- **Relationship integrity:** validation of the relationships between accounts, subscriptions, and invoices, as well as the reconciliation of customer identifiers between HubSpot and Subskribe.
- **Subscription lifecycle:** analysis of subscription states, date consistency, renewal chains, and renewal continuity to understand how customer lifecycles are represented in the source data.
- **Invoice and revenue behavior:** analysis of invoice statuses, amounts, billing frequency, and invoice distribution to establish reliable revenue rules.

These checks were used not only to identify data quality issues, but also to derive business rules and guide the design of the analytical models.


### Modeling Approach

The dbt project follows a three-layer modeling approach to separate source preparation, business logic, and analytics-ready datasets.

- **Staging:** standardizes the raw HubSpot and Subskribe data through column renaming, type casting, and basic cleaning while remaining close to the source.
- **Intermediate:** handles reusable business logic and more complex transformations, including customer identifier reconciliation and subscription lifecycle reconstruction.
- **Marts:** provides business-ready dimensional models for analytics and reporting, organized around customers, subscriptions, invoices, and dates.

This separation keeps source-specific transformations isolated from business logic and makes the models easier to understand, test, and maintain.


### Customer Identity Resolution

One of the main modeling challenges was reconciling customer identities between HubSpot and Subskribe.

Subskribe accounts reference HubSpot companies through a CRM identifier, but some of these identifiers no longer matched the current HubSpot company_id. Investigation of the HubSpot data showed that most unmatched identifiers corresponded to historical company IDs stored in merged_object_ids, resulting from company records that had previously been merged.

A dedicated intermediate model, int_hubspot__company_id_mapping, was created to resolve both current and historical HubSpot identifiers to the appropriate company.

This reconciliation logic was intentionally kept separate from dim_customers to centralize identity resolution, avoid duplicating mapping logic, and keep the final customer dimension focused on analytics-ready attributes.

Identifiers that could not be reliably reconciled were left unresolved rather than forcing an uncertain customer relationship.


### Analytics Marts

The final analytics layer consists of four business-ready models:

- **dim_customers:** unified customer information from HubSpot and Subskribe.
- **dim_date:** shared calendar dimension for time-based analysis.
- **fct_subscriptions:** subscription lifecycle and renewal history.
- **fct_invoices:** invoice and billed revenue analysis.

These models form the analytics layer designed to support reporting and visualization in Power BI.


## Data Quality & Testing

Data quality checks are integrated directly into the dbt workflow and executed automatically during dbt builds.

The testing strategy combines generic dbt tests with custom singular tests covering:

- primary key uniqueness and non-null constraints;
- accepted values for controlled fields such as subscription and invoice statuses;
- referential integrity between related models;
- custom business rules and relationships that cannot be validated through generic tests alone.

These tests help detect data quality issues and business logic inconsistencies before changes are deployed to production.


## CI/CD & Environments

The project separates development, continuous integration, and production environments to isolate development work from automated validation and production deployments.

- **DEV — dbt_karim:** development environment used for building and validating dbt models.
- **CI — dbt_ci:** isolated environment used by GitHub Actions to validate pull requests before merging.
- **PROD — dbt_prod_technical / analytics:** production environment separating technical transformation models from business-facing analytics marts.

GitHub Actions automates both validation and deployment:

- **CI:** each pull request to main runs a complete dbt build in the isolated CI environment.
- **CD:** each merge to main triggers a production dbt build and deploys the validated models to the production datasets.

Dedicated GCP service accounts and dataset-level permissions are used for each environment to maintain separation of responsibilities and limit access.


## Power BI Dashboard

### Executive Overview

The Executive Overview dashboard provides a consolidated view of SaaS business performance through key revenue, customer, and churn metrics.

Built with Power BI, it features custom KPI cards powered by DAX measures, dynamic year and month slicers, MoM and YoY comparisons, conditional formatting, interactive cross-filtering, informational tooltips, and bookmark-driven visual navigation.

**Data Coverage:** The dataset covers SaaS activity through April 2026, the last complete month available for analysis. Reporting is limited to this period to ensure consistent monthly KPIs and avoid comparisons based on incomplete months.

![SaaS Revenue Analytics - Executive Overview](powerbi/executive-overview.png)
