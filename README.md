# SaaS Revenue Analytics

## Project Overview

SaaS Revenue Analytics is an end-to-end Analytics Engineering project built around CRM and billing data from HubSpot and Subskribe.

The project transforms raw operational data into reliable, analytics-ready datasets for analyzing customers, subscriptions, invoices, and SaaS revenue.

The project is designed as a modern analytics workflow covering data ingestion, transformation and
modeling with BigQuery and dbt, data quality testing, environment separation,
automated CI/CD pipelines, business intelligence with Power BI, and workflow
orchestration with Airflow.

Docker is used to containerize the Airflow environment, providing a consistent foundation for local development and future production deployment on a Google Cloud VM. Infrastructure as Code with Terraform is also planned to support cloud infrastructure provisioning.


## Project Roadmap

- [x] Data ingestion and BigQuery setup
- [x] dbt staging, intermediate and marts
- [x] Data quality testing
- [x] DEV / CI / PROD environment separation
- [x] CI pipeline (dbt and Airflow)
- [x] CD pipeline (dbt)
- [x] Power BI - Executive Overview
- [ ] Power BI - Revenue & Customer Retention
- [ ] Power BI - Customer Analysis
- [x] Docker containerization
- [x] Airflow DEV orchestration
- [ ] Airflow PROD orchestration and deployment
- [ ] Terraform infrastructure


## Architecture

The project follows a layered analytics architecture with separate development, CI, and production environments.

```text
                         HubSpot / Subskribe
                                  │
                                  ▼
                         Google Cloud Storage
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
                 ┌────────────────┼─────────────────────┐
                 │                │                     │
                 ▼                ▼                     ▼
            DEVELOPMENT           CI                PRODUCTION
             dbt_karim          dbt_ci                  │
                 │                │                     │
          stg / int / marts  stg / int / marts   ┌──────┴──────┐
                                                 │             │
                                                 ▼             ▼
                                        dbt_prod_technical  analytics
                                              stg / int       marts
                                                               │
                                                               ▼
                                                            Power BI
```
The development pipeline is orchestrated locally using Apache Airflow and Docker. Airflow manages data ingestion from Google Cloud Storage into BigQuery RAW, followed by dbt transformations and data quality tests in the DEV environment.

GitHub Actions handles CI/CD independently, validating dbt models and Airflow DAGs during pull requests and executing dbt transformations in production after merging into 'main'.


## Data Source & Credits

This project is based on the public Tracksuit Data Engineer Analytics take-home task.

The original business case and sample HubSpot and Subskribe datasets were provided by Tracksuit.

Original source: [Tracksuit Data Engineer Analytics Take-Home Task](https://github.com/gotracksuit/tracksuit-data-engineer-analytics-take-home-task-public)

The project was independently extended into a complete Analytics Engineering workflow, including data architecture, dbt modeling, data quality testing, environment separation, automated CI/CD, and containerized workflow orchestration with Docker and Airflow.


## Data Ingestion & Orchestration

The development pipeline is orchestrated using Apache Airflow 3.1.8 running locally with Docker Compose.

Two Airflow DAGs manage the workflow:

- **gcs_to_bigquery_raw:** ingests the four source CSV files from Google Cloud Storage into the shared BigQuery RAW dataset, replacing existing table contents on each run.
- **saas_revenue_pipeline_dev:** triggers RAW ingestion and, upon successful completion, executes the dbt DEV build, including transformations and data quality tests.

A dedicated GCP service account is used for RAW ingestion, with permissions restricted to reading source files from GCS and writing to the BigQuery RAW dataset.

Production orchestration using Airflow and Docker on a Google Cloud VM is planned for a later stage.


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

- **DEV - dbt_karim:** development environment used for building and validating dbt models, with local Airflow orchestration running through Docker.
- **CI - dbt_ci:** isolated environment used by GitHub Actions to validate pull requests before merging.
- **PROD - dbt_prod_technical / analytics:** production environment separating technical transformation models from business-facing analytics marts.

GitHub Actions manages automated validation and deployment through existing and planned workflows:

- **dbt CI:** each pull request to 'main' runs a complete dbt build in the isolated CI environment.
- **Airflow CI:** each pull request to 'main' validates DAG Python syntax, imports, and expected DAG availability using the Airflow Docker image.
- **dbt CD:** each merge to 'main' triggers a production dbt build in the production datasets.
- **Airflow CD (planned):** automatically deploys the production Airflow environment and DAGs to a Google Cloud VM using Docker when relevant changes are merged into 'main'.

Dedicated GCP service accounts and dataset-level permissions are used to maintain environment separation and limit access.


## Power BI Dashboard

### Executive Overview

The Executive Overview dashboard provides a consolidated view of SaaS business performance through key revenue, customer, and churn metrics.

Built with Power BI, it features custom KPI cards powered by DAX measures, dynamic year and month slicers, MoM and YoY comparisons, conditional formatting, interactive cross-filtering, informational tooltips, and bookmark-driven visual navigation.

**Data Coverage:** The dataset covers SaaS activity through April 2026, the last complete month available for analysis. Reporting is limited to this period to ensure consistent monthly KPIs and avoid comparisons based on incomplete months.

![SaaS Revenue Analytics - Executive Overview](powerbi/executive-overview.png)
