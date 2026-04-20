# Mode-Startup-Workforce-Intelligence-Database-Architecture
# Project Overview
Architected a normalized HR database, programmatically generated 1k rows of mock data using Recursive CTEs, and engineered complex SQL queries to extract stakeholder ready BI metrics on gender pay equity, departmental headcount, and budget allocation.
# Objectives
Architect a normalized relational database with three core tables (Demographics, Salary, Departments).
Utilize Recursive Common Table Expressions (CTEs) to programmatically generate a large dataset for testing and analysis.
Write complex queries to answer high-level stakeholder questions regarding finance, pay equity, and organizational structure.
# Tech Stack
Language: SQL
Techniques Used: Recursive CTEs, Data Normalization, JOIN operations (Inner, Left), Aggregations, CASE statements, Data Formatting (COALESCE, ROUND).
# Database Schema
The database consists of three interconnected tables:
mode_startup_departments: Lookup table for departmental hierarchy.
employee_demographics: Stores core identity data (Age, Gender, Birth Date).
employee_salary: Stores compensation and role data, linked to departments and demographics via foreign keys.
# Key Business Insights Extracted
Financial Metrics: Calculated total annual payroll liability and department-level budget allocations to identify the highest capital consumers.
HR & Governance: Conducted Gender Pay Equity analysis and mapped compensation trends across different employee age brackets using conditional logic.
Operational Efficiency: Analyzed departmental headcount and organizational structure (ratio of managers to technicians) to assess workforce distribution.
# How to Run
Clone this repository.
Open your preferred SQL editor (e.g., MySQL Workbench).
Execute the mode_startup.sql script to build the database, generate the data, and view the analytical output.
